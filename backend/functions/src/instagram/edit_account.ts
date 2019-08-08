import { CallableContext } from 'firebase-functions/lib/providers/https';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import {
  IgApiClient, IgCheckpointError, IgLoginBadPasswordError, IgLoginInvalidUserError, IgLoginTwoFactorRequiredError,
} from 'instagram-private-api';

export default async function editAccount(data: any, context: CallableContext): Promise<{ checkpoint: any, message: string } | null> {

  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  if ((!data.username && !data.password) || !data.id) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called with required parameters.');
  }

  const uid = context.auth.uid;
  const accountId = data.id;

  let result: { checkpoint: any, message: string } | null = null;

  const accountDoc = await admin.firestore().collection('users').doc(uid).collection('accounts').doc(accountId).get();

  let username;
  let password;

  if (data.username === null || data.username.length === 0) {
    username = accountDoc.data()!.username;
    data.username = username;
  } else {
    username = data.username;
  }

  if (data.password === null || data.password.length === 0) {
    password = await (await import('./decrypt_password')).default(uid, accountDoc.data()!.encryptedPassword);
    data.password = password;
  } else {
    password = data.password;
  }

  const instagram = new IgApiClient();

  instagram.state.generateDevice(username);

  await instagram.simulate.preLoginFlow();

  try {
    await instagram.account.login(username, password);
    await editInstagramAccount(instagram, data, context, 'running');

    result = {
      checkpoint: null,
      message: 'success'
    }
  } catch (e) {
    if (e instanceof IgLoginBadPasswordError) {
      console.log('Bad password');
      throw new functions.https.HttpsError('invalid-argument', 'Invalid Instagram password.');
    } else if (e instanceof IgLoginInvalidUserError) {
      console.log('Invalid user');
      throw new functions.https.HttpsError('invalid-argument', 'Invalid Instagram user.');
    } else if (e instanceof IgCheckpointError) {
      console.log('Checkpoint error');
      await editInstagramAccount(instagram, data, context, 'checkpoint-required');

      console.log(instagram.state.checkpoint);
      await instagram.challenge.auto(true);
      result = {
        checkpoint: instagram.state.checkpoint,
        message: 'checkpoint-required'
      }
    } else if (e instanceof IgLoginTwoFactorRequiredError) {
      await editInstagramAccount(instagram, data, context, 'two-factor-required', e.response.body.two_factor_info.two_factor_identifier);

      result = {
        checkpoint: instagram.state.checkpoint,
        message: 'two-factor-required'
      }
    } else {
      throw new functions.https.HttpsError('unknown', 'Unknown error.');
    }
  }

  return result;
}

async function editInstagramAccount(instagram: IgApiClient, data: { username: string, password: string, id: string}, context: CallableContext, status: string, twoFactorIdentifier: string | null = null) {
  console.log('Editing instagram account!');
  const cookies = await instagram.state.serializeCookieJar();

  let profilePictureURL: any = null;

  console.log('Getting profile picture!');
  try {
    profilePictureURL = (await instagram.account.currentUser()).profile_pic_url;
  } catch (e) { }

  console.log(profilePictureURL);

  const state = {
    checkpoint: instagram.state.checkpoint,
    deviceString: instagram.state.deviceString,
    deviceId: instagram.state.deviceId,
    uuid: instagram.state.uuid,
    phoneId: instagram.state.phoneId,
    adid: instagram.state.adid,
    build: instagram.state.build,
  };

  console.log('Password');

  const encryptedPassword = await (await import('./encrypt_password')).default({
    password: data.password
  }, context);

  await admin.firestore().collection('users').doc(context.auth!.uid).collection('accounts').doc(data.id).update({
    username: data.username,
    encryptedPassword: encryptedPassword,
    cookies: cookies,
    state: state,
    twoFactorIdentifier: twoFactorIdentifier,
    status: status,
    profilePictureURL: profilePictureURL,
  });
}