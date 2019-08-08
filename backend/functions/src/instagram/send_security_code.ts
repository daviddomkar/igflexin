import { CallableContext } from "firebase-functions/lib/providers/https";
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {
  IgApiClient, IgLoginBadPasswordError, IgLoginInvalidUserError,
  IgLoginTwoFactorRequiredError
} from "instagram-private-api";

export default async function sendSecurityCode(data: any, context: CallableContext): Promise<{ checkpoint: any, message: string } | null> {

  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  if (!data.securityCode || !data.username) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called with required parameters.');
  }

  const uid = context.auth.uid;
  const username = data.username;
  const securityCode = data.securityCode;

  const accountReference = admin.firestore().collection('users').doc(uid).collection('accounts').where('username', '==', username).limit(1);
  const accountDoc = (await accountReference.get()).docs[0];
  const account = accountDoc.data()!;

  const cookies = account.cookies;
  const state = account.state;

  const instagram = new IgApiClient();

  instagram.state.generateDevice(username);

  let status = 'running';
  let result = null;

  await instagram.state.deserializeCookieJar(cookies);
  instagram.state.checkpoint = state.checkpoint;
  instagram.state.deviceString = state.deviceString;
  instagram.state.deviceId = state.deviceId;
  instagram.state.uuid = state.uuid;
  instagram.state.phoneId = state.phoneId;
  instagram.state.adid = state.adid;
  instagram.state.build = state.build;

  await instagram.challenge.sendSecurityCode(securityCode);

  let profilePictureURL = null;
  let twoFactorIdentifier = null;

  try {
    profilePictureURL = (await instagram.account.currentUser()).profile_pic_url;

    result = {
      checkpoint: null,
      message: 'success'
    }
  } catch (e) {
    if (e instanceof IgLoginTwoFactorRequiredError) {
      console.log('Two factor required');

      status = 'two-factor-required';

      twoFactorIdentifier = e.response.body.two_factor_info.two_factor_identifier;

      result = {
        checkpoint: instagram.state.checkpoint,
        message: 'two-factor-required'
      }
    } else if (e instanceof IgLoginBadPasswordError) {
      console.log('Bad password');
      status = 'bad-password';
      throw new functions.https.HttpsError('invalid-argument', 'Invalid Instagram password.');
    } else if (e instanceof IgLoginInvalidUserError) {
      console.log('Invalid user');
      status = 'invalid-user';
      throw new functions.https.HttpsError('invalid-argument', 'Invalid Instagram user.');
    } else {
      throw new functions.https.HttpsError('unknown', 'Unknown error.');
    }

    console.log(e);
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

  await admin.firestore().collection('users').doc(uid).collection('accounts').doc(accountDoc.id).update({
    cookies: cookiesToSave,
    state: stateToSave,
    status: status,
    profilePictureURL: profilePictureURL,
    twoFactorIdentifier: twoFactorIdentifier,
  });

  return result;
}