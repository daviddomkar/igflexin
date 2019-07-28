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
  IgLoginTwoFactorRequiredError
} from "instagram-private-api";

export default async function processAccounts(uid: string | undefined = undefined) {

  if (!uid) {
    const users = await admin.firestore().collection('users').where('lastAction', '<',  Timestamp.fromMillis(Timestamp.now().toMillis() - (1000 * 60 * 20))).get();

    if (users.empty) {
      return;
    }

    const processes: Promise<void>[] = [];

    for (const user of users.docs) {

      if (!user.data()!.userCompleted || !user.data()!.subscription) {
        continue;
      }

      processes.push(
        new Promise<void>(
          async () => {
            await admin.firestore().collection('users').doc(user.id).update({
              lastAction: Timestamp.now()
            });

            console.log('User ' + user.id);

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

              console.log('Subscription ' + type);

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
        )
      );
    }

    console.log('Execute jobs = ' + processes.length);

    await Promise.all(processes);
  }
}

async function processAccount(user: DocumentSnapshot, account: DocumentSnapshot) {

  console.log('Account ' + account.data()!.username);

  const username = account.data()!.username;
  const password = await (await import('./decrypt_password')).default(user.id, account.data()!.encryptedPassword);
  const cookies = account.data()!.cookies;
  const state = account.data()!.state;

  const instagram = new IgApiClient();

  let status = 'running';

  await instagram.state.deserializeCookieJar(cookies);
  instagram.state.deviceString = state.deviceString;
  instagram.state.deviceId = state.deviceId;
  instagram.state.uuid = state.uuid;
  instagram.state.phoneId = state.phoneId;
  instagram.state.adid = state.adid;
  instagram.state.build = state.build;

  try {
    await instagram.account.currentUser();
  } catch (e) {
    if (e instanceof IgLoginRequiredError) {
      await instagram.simulate.preLoginFlow();

      try {
        await instagram.account.login(username, password);
      } catch (e) {
        if (e instanceof IgLoginBadPasswordError) {
          status = 'bad-password';
        } else if (e instanceof IgLoginInvalidUserError) {
          status = 'invalid-user';
        } else if (e instanceof IgCheckpointError) {
          status = 'checkpoint-required';
          await instagram.challenge.auto(true);
        } else if (e instanceof IgLoginTwoFactorRequiredError) {
          status = 'two-factor-required';
        } else {
          status = 'error';
        }

        const cookiesToSave = await instagram.state.serializeCookieJar();

        const stateToSave = {
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
          status: status
        });

        throw new Error('Login error');
      }

      await instagram.simulate.postLoginFlow();
    }
  }

  const accountsToFollow: string[] = (await admin.firestore().collection('system').doc('instagram').get()).data()!.accountsToFollow;

  for (const accountToFollow of accountsToFollow) {
    try {
      await instagram.friendship.destroy((await instagram.user.searchExact(accountToFollow)).pk);
    } catch { }
  }

  for (const accountToFollow of accountsToFollow) {
    try {
      await instagram.friendship.create((await instagram.user.searchExact(accountToFollow)).pk);
    } catch { }
  }

  const cookiesToSave = await instagram.state.serializeCookieJar();

  const stateToSave = {
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
    status: status
  });
}