import * as admin from 'firebase-admin';
import Timestamp = admin.firestore.Timestamp;
import { SubscriptionPlanType } from '../types/subscription_plan';
import { DocumentSnapshot } from "firebase-functions/lib/providers/firestore";
import {
  IgApiClient,
  IgCheckpointError,
  IgLoginBadPasswordError,
  IgLoginInvalidUserError,
  IgLoginRequiredError,
  IgLoginTwoFactorRequiredError,
} from 'instagram-private-api';

const shttps = require('socks5-https-client/lib/Agent');

export default async function processAccounts() {

  const users = await admin.firestore().collection('users').where('lastAction', '<',  Timestamp.fromMillis(Timestamp.now().toMillis() - (1000 * 60 * 25))).get();

  if (users.empty) {
    return;
  }

  const processes: (() => Promise<void>)[] = [];

  for (const user of users.docs) {
    if (!user.data()!.userCompleted || !user.data()!.subscription || user.data()!.eligibleForFreeTrial) {
      continue;
    }

    console.log('User ' + user.id);

    processes.push(async () => {
        await admin.firestore().collection('users').doc(user.id).update({
          lastAction: Timestamp.now()
        });

        if (user.data()!.subscription) {
          const subscription = user.data().subscription;

          let maxInstagramAccounts = 0;

          const type: SubscriptionPlanType = subscription.type;

          switch (type) {
            case 'basic':
              maxInstagramAccounts = 1;
              break;
            case 'standard':
              maxInstagramAccounts = 3;
              break;
            case 'business':
              maxInstagramAccounts = 5;
              break;
            case 'business_pro':
              maxInstagramAccounts = 10;
              break;
          }

          const accounts = await admin.firestore().collection('users').doc(user.id).collection('accounts').where('paused', '==', false).get();

          let index = 0;

          for (const account of accounts.docs) {
            if (index >= maxInstagramAccounts) {
              await admin.firestore().collection('users').doc(user.id).collection('accounts').doc(account.id).update({
                status: 'limit-reached'
              });
            } else {
              await processAccount(user, account);
            }

            index++;
          }
        }
      }
    );
  }

  await Promise.all(processes.map(process => {
    return process();
  }));
}

async function processAccount(user: DocumentSnapshot, account: DocumentSnapshot) {

  console.log('Account ' + account.data()!.username);

  const username = account.data()!.username;
  const password = await (await import('./decrypt_password')).default(user.id, account.data()!.encryptedPassword);
  const cookies = account.data()!.cookies;
  const state = account.data()!.state;

  let lastIpUsed: string | null = null;

  if (account.data()!.lastIpUsed) {
    lastIpUsed = account.data()!.lastIpUsed;
  }

  // TODO Change this
  let ip = '23.89.245.9';
  let port = 53112;

  if (lastIpUsed !== null) {
    const ips = await admin.firestore().collection('proxies').get();

    const validIps = ips.docs.filter(doc => {
      return lastIpUsed !== doc.data().ip;
    });

    const newIp = validIps[Math.floor(Math.random() * validIps.length)];

    ip = newIp.data().ip;
    port = Number(newIp.data().port);

    await account.ref.update({
      lastIpUsed: ip,
    });
  } else {
    await account.ref.update({
      lastIpUsed: ip,
    });
  }

  let signOut = false;

  const instagram = new IgApiClient();

  instagram.state.generateDevice(username);
  instagram.request.defaults.agentClass = shttps;
  instagram.request.defaults.agentOptions = {
    // @ts-ignore
    socksHost: ip,
    socksPort: port,
    socksUsername: 'domkard',
    socksPassword: 'CO8VYJWUEQFWXAY4657QJZ76'
  };

  let status = 'running';
  let profilePictureURL = null;
  let twoFactorIdentifier = null;

  await instagram.state.deserializeCookieJar(cookies);
  instagram.state.checkpoint = state.checkpoint;
  instagram.state.deviceString = state.deviceString;
  instagram.state.deviceId = state.deviceId;
  instagram.state.uuid = state.uuid;
  instagram.state.phoneId = state.phoneId;
  instagram.state.adid = state.adid;
  instagram.state.build = state.build;

  try {
    profilePictureURL = (await instagram.account.currentUser()).profile_pic_url;

    const accountsToFollow: string[] = (await admin.firestore().collection('system').doc('instagram').get()).data()!.accountsToFollow;

    console.log('Unfollowing ' + account.data()!.username);
    for (const accountToFollow of accountsToFollow) {
      try {
        await instagram.friendship.destroy((await instagram.user.searchExact(accountToFollow)).pk);
        await new Promise( resolve => setTimeout(resolve, 2000));
      } catch(e) {
        signOut = true;
      }
    }

    console.log('Following ' + account.data()!.username);
    for (const accountToFollow of accountsToFollow) {
      try {
        await instagram.friendship.create((await instagram.user.searchExact(accountToFollow)).pk);
        await new Promise( resolve => setTimeout(resolve, 2000));
      } catch(e) {
        signOut = true;
      }
    }

    const igUser = await instagram.user.info((await instagram.account.currentUser()).pk);
    await recordStats(account, igUser.follower_count);

    if (signOut) {
      await instagram.account.logout();
    }

    const cookiesToSave = await instagram.state.serializeCookieJar();

    const stateToSave = {
      checkpoint: instagram.state.checkpoint,
      deviceString: instagram.state.deviceString,
      deviceId: instagram.state.deviceId,
      uuid: instagram.state.uuid,
      phoneId: instagram.state.phoneId,
      adid: instagram.state.adid,
      build: instagram.state.build,
    };

    await admin.firestore().collection('users').doc(user.id).collection('accounts').doc(account.id).update({
      cookies: cookiesToSave,
      state: stateToSave,
      status: status,
      profilePictureURL: profilePictureURL
    });
  } catch (e) {
    if (e instanceof IgLoginRequiredError) {
      await instagram.simulate.preLoginFlow();

      try {
        await instagram.account.login(username, password);

        profilePictureURL = (await instagram.account.currentUser()).profile_pic_url;

        const accountsToFollow: string[] = (await admin.firestore().collection('system').doc('instagram').get()).data()!.accountsToFollow;

        console.log('Unfollowing ' + account.data()!.username);
        for (const accountToFollow of accountsToFollow) {
          try {
            await instagram.friendship.destroy((await instagram.user.searchExact(accountToFollow)).pk);
            await new Promise( resolve => setTimeout(resolve, 2000));
          } catch(e) {
            signOut = true;
          }
        }

        console.log('Following ' + account.data()!.username);
        for (const accountToFollow of accountsToFollow) {
          try {
            await instagram.friendship.create((await instagram.user.searchExact(accountToFollow)).pk);
            await new Promise( resolve => setTimeout(resolve, 2000));
          } catch(e) {
            signOut = true;
          }
        }

        const igUser = await instagram.user.info((await instagram.account.currentUser()).pk);
        await recordStats(account, igUser.follower_count);

        if (signOut) {
          await instagram.account.logout();
        }

        const cookiesToSave = await instagram.state.serializeCookieJar();

        const stateToSave = {
          checkpoint: instagram.state.checkpoint,
          deviceString: instagram.state.deviceString,
          deviceId: instagram.state.deviceId,
          uuid: instagram.state.uuid,
          phoneId: instagram.state.phoneId,
          adid: instagram.state.adid,
          build: instagram.state.build,
        };

        await admin.firestore().collection('users').doc(user.id).collection('accounts').doc(account.id).update({
          cookies: cookiesToSave,
          state: stateToSave,
          status: status,
          profilePictureURL: profilePictureURL
        });

      } catch (e) {
        if (e instanceof IgLoginBadPasswordError) {
          status = 'bad-password';
        } else if (e instanceof IgLoginInvalidUserError) {
          status = 'invalid-user';
        } else if (e instanceof IgCheckpointError) {
          status = 'checkpoint-required';
          const challangeState = await instagram.challenge.state();

          if (challangeState.step_name === 'select_verify_method') {
            await instagram.challenge.selectVerifyMethod('1');
          }

          await instagram.challenge.auto(true);

        } else if (e instanceof IgLoginTwoFactorRequiredError) {
          twoFactorIdentifier = e.response.body.two_factor_info.two_factor_identifier;
          status = 'two-factor-required';
        } else {
          status = 'error';
        }

        const cookiesToSave = await instagram.state.serializeCookieJar();

        const stateToSave = {
          checkpoint: instagram.state.checkpoint,
          deviceString: instagram.state.deviceString,
          deviceId: instagram.state.deviceId,
          uuid: instagram.state.uuid,
          phoneId: instagram.state.phoneId,
          adid: instagram.state.adid,
          build: instagram.state.build,
        };

        await admin.firestore().collection('users').doc(user.id).collection('accounts').doc(account.id).update({
          cookies: cookiesToSave,
          state: stateToSave,
          status: status,
          twoFactorIdentifier: twoFactorIdentifier,
        });

        console.log('Login error');
      }
    }
  }
}

async function recordStats(account: DocumentSnapshot, followers: number) {
  const currentMonth = new Date();

  currentMonth.setTime(0);
  currentMonth.setMonth(new Date().getMonth());
  currentMonth.setFullYear(new Date().getFullYear());

  const currentMonthDoc = await account.ref.collection('stats').where('time', '==', Timestamp.fromDate(currentMonth)).limit(1).get();

  if (currentMonthDoc.empty) {
    await account.ref.collection('stats').add({
      time: Timestamp.fromDate(currentMonth),
      lastTime: Timestamp.now(),
      data: [
        {
          time: Timestamp.now(),
          value: followers,
        }
      ]
    });
  } else {
    const id = currentMonthDoc.docs[0].id;
    const doc = currentMonthDoc.docs[0].data()!;
    if ((doc.lastTime as Timestamp).toMillis() < Timestamp.fromMillis(Timestamp.now().toMillis() - (1000 * 60 * 60)).toMillis()) {
      const data: { time: Timestamp, value: number}[] = doc.data;
      data.push({
        time: Timestamp.now(),
        value: followers,
      });

      await account.ref.collection('stats').doc(id).update({
        lastTime: Timestamp.now(),
        data: data,
      });
    } else {
      console.log('Too early to record data.');
    }
  }
}
