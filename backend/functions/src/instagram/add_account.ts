import { CallableContext } from 'firebase-functions/lib/providers/https';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import {
  IgApiClient,
  IgCheckpointError,
  IgLoginBadPasswordError,
  IgLoginInvalidUserError,
  IgLoginTwoFactorRequiredError
} from 'instagram-private-api';
import { SubscriptionPlanType } from '../types/subscription_plan';
// tslint:disable-next-line:no-implicit-dependencies
import { Transaction } from '@google-cloud/firestore';

export default async function addAccount(data: any, context: CallableContext): Promise<{ checkpoint: any, message: string } | null> {

  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  if (!data.username || !data.password) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called with required parameters.');
  }

  const uid = context.auth.uid;

  let result: { checkpoint: any, message: string } | null = null;

  await admin.firestore().runTransaction(async transaction => {
    const account = await admin.firestore().collectionGroup('accounts').where('username', '==', data.username).get();

    if (!account.empty) {
      throw new functions.https.HttpsError('permission-denied', 'This account is already added to IGFlexin.');
    }

    const userData = await admin.firestore().collection('users').doc(uid).get();

    let maxInstagramAccounts = 0;

    if (userData.exists && userData.data()!.subscription) {

      const subscription = userData.data()!.subscription;
      const type: SubscriptionPlanType = subscription.type;

      switch (type) {
        case "basic":
          maxInstagramAccounts = 1;
          break;
        case "standard":
          maxInstagramAccounts = 3;
          break;
        case "business":
          maxInstagramAccounts = 5;
          break;
        case "business_pro":
          maxInstagramAccounts = 10;
          break;
      }
    } else {
      throw new functions.https.HttpsError('failed-precondition', 'User data must exist.');
    }

    const accounts = await admin.firestore().collection('users').doc(uid).collection('accounts').get();

    if (accounts.size >= maxInstagramAccounts) {
      throw new functions.https.HttpsError('permission-denied', 'Account limit reached.');
    }

    const username = data.username;
    const password = data.password;

    const instagram = new IgApiClient();

    instagram.state.generateDevice(username);

    await instagram.simulate.preLoginFlow();

    try {
      await instagram.account.login(username, password);
    } catch (e) {
      if (e instanceof IgLoginBadPasswordError) {
        console.log('Bad password');
        throw new functions.https.HttpsError('invalid-argument', 'Invalid Instagram password.');
      } else if (e instanceof IgLoginInvalidUserError) {
        console.log('Invalid user');
        throw new functions.https.HttpsError('invalid-argument', 'Invalid Instagram user.');
      } else if (e instanceof IgCheckpointError) {
        console.log('Checkpoint error');
        await addInstagramAccount(transaction, instagram, data, context, 'checkpoint-required');

        console.log(instagram.state.checkpoint);
        await instagram.challenge.auto(true);
        result = {
          checkpoint: instagram.state.checkpoint,
          message: 'checkpoint-required'
        }
      } else if (e instanceof IgLoginTwoFactorRequiredError) {
        console.log('Two factor required');
        await addInstagramAccount(transaction, instagram, data, context, 'two-factor-required');

        result = {
          checkpoint: instagram.state.checkpoint,
          message: 'two-factor-required'
        }
      } else {
        throw new functions.https.HttpsError('unknown', 'Unknown error.');
      }
    }

    process.nextTick(async () => await instagram.simulate.postLoginFlow());

    await addInstagramAccount(transaction, instagram, data, context, 'running');

    result = {
      checkpoint: null,
      message: 'success'
    }
  });

  console.log(result);

  return result;
}

async function addInstagramAccount(transaction: Transaction, instagram: IgApiClient, data: { username: string, password: string }, context: CallableContext, status: string) {
  const cookies = await instagram.state.serializeCookieJar();

  const user = await instagram.user.searchExact(data.username);

  const state = {
    deviceString: instagram.state.deviceString,
    deviceId: instagram.state.deviceId,
    uuid: instagram.state.uuid,
    phoneId: instagram.state.phoneId,
    adid: instagram.state.adid,
    build: instagram.state.build,
  };

  const encryptedPassword = await (await import('./encrypt_password')).default({
    password: data.password
  }, context);

  transaction.create(admin.firestore().collection('users').doc(context.auth!.uid).collection('accounts').doc(), {
    username: data.username,
    encryptedPassword: encryptedPassword,
    cookies: cookies,
    state: state,
    paused: false,
    status: status,
    profilePictureURL: user.profile_pic_url
  });
}