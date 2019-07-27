import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from 'firebase-admin';
import * as functions from "firebase-functions";
import {cloudkms_v1, google} from 'googleapis';
import * as crypto from 'crypto';
import * as cryptojs from "crypto-js";

const KMS_MANAGER_SERVICE_ACCOUNT_FILE = '../igflexin-5d2db-1b141234f3a2.json';
const IGFlexinKMSManagerServiceAccount = require(KMS_MANAGER_SERVICE_ACCOUNT_FILE);
const jwtKMSManagerClient = new google.auth.JWT(IGFlexinKMSManagerServiceAccount.client_email, KMS_MANAGER_SERVICE_ACCOUNT_FILE, IGFlexinKMSManagerServiceAccount.private_key, ['https://www.googleapis.com/auth/cloud-platform'], undefined, undefined);
const kms = new cloudkms_v1.Cloudkms({auth: jwtKMSManagerClient});

export default async function encryptPassword(data: any, context: CallableContext): Promise<string> {

  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  if (!data.password) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called with required parameters.');
  }

  console.log('Encrypt password');

  const uid = context.auth.uid;

  const keyDoc = await admin.firestore().collection('keys').doc(uid).get();

  let key;

  if (keyDoc.exists) {
    const result = await kms.projects.locations.keyRings.cryptoKeys.decrypt({
      name: 'projects/igflexin-5d2db/locations/global/keyRings/igflexin/cryptoKeys/password',
      requestBody: {
        ciphertext: keyDoc.data()!.key
      }
    });

    key = result.data.plaintext;
  } else {
    const secureKey = hashString(uid, getRandomString(16));

    const result = await kms.projects.locations.keyRings.cryptoKeys.encrypt({
      name: 'projects/igflexin-5d2db/locations/global/keyRings/igflexin/cryptoKeys/password',
      requestBody: {
        plaintext: Buffer.from(secureKey).toString('base64')
      }
    });

    await admin.firestore().collection('keys').doc(uid).set({
      key: result.data.ciphertext
    });

    key = Buffer.from(secureKey).toString('base64');
  }

  console.log(key);
  console.log(cryptojs.AES.encrypt(data.password, key!).toString(cryptojs.enc.Utf8));

  return cryptojs.AES.encrypt(data.password, key!).toString(cryptojs.enc.Utf8);
}

function hashString(string: string, salt: string) {
  const hash = crypto.createHmac('sha512', salt);
  hash.update(string);

  return hash.digest('hex');
}

function getRandomString(length: number) {
  return crypto.randomBytes(Math.ceil(length / 2)).toString('hex').slice(0, length);
}