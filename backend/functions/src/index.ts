import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// import * as crypto from 'crypto';
//import * as cryptojs from "crypto-js";
// import {cloudkms_v1, google} from 'googleapis';
// import {IgApiClient, IgCheckpointError} from 'instagram-private-api';
// import Timestamp = admin.firestore.Timestamp;
import { pubSub, initialSubscriptionPurchase } from './stripe';

admin.initializeApp();

export const createUserData = functions.https.onCall(async (data, context) => {
  await (await import('./core/create_user_data')).default(data, context);
});

export const stripe = functions.pubsub.topic('stripe').onPublish(pubSub);
export const stripeInitialSubscriptionPurchase = functions.https.onCall(initialSubscriptionPurchase);

/*
const firestore = admin.firestore();

const KMS_MANAGER_SERVICE_ACCOUNT_FILE = './igflexin-5d2db-1b141234f3a2.json';
const IGFlexinKMSManagerServiceAccount = require(KMS_MANAGER_SERVICE_ACCOUNT_FILE);

const jwtKMSManagerClient = new google.auth.JWT(IGFlexinKMSManagerServiceAccount.client_email, KMS_MANAGER_SERVICE_ACCOUNT_FILE, IGFlexinKMSManagerServiceAccount.private_key, ['https://www.googleapis.com/auth/cloud-platform'], undefined, undefined);

const kms = new cloudkms_v1.Cloudkms({auth: jwtKMSManagerClient});
*/

/*
export const runner = functions
  .runWith({memory: '2GB'})
  .pubsub.schedule('* * * * *')
  .onRun(async () => {
    const accounts = await firestore.collection('accounts')
      .where('lastAction', '<', Timestamp.fromDate(new Date(Date.now() - (1000 * 60 * 20))))
      .get();

    const jobs: Promise<void>[] = [];

    if (!accounts.empty) {
      accounts.docs.forEach((account) => {
        if (account.exists) {
          console.log(account.data()['userID']);

          jobs.push(new Promise<void>(
            async () => {
              const key = await getUserKey(account.data()['userID']);

              const username = account.data()['username'];
              const password = cryptojs.AES.decrypt(account.data()['encryptedPassword'], key!).toString(cryptojs.enc.Utf8);

              await processAccount(username, password);
            }
          ));
        }
      });
    }

    await Promise.all(jobs);
  }
);
*/

/*
// @ts-ignore
async function processAccount(username: string, password: string) {
  const ig = new IgApiClient();
  ig.state.generateDevice(username);
  try {

    const auth = await ig.account.login(username, password);
    console.log(auth);
  } catch (e) {
    if (e instanceof IgCheckpointError) {
      console.log(e.apiUrl);
      console.log(e.url);
    }
  }
}

// @ts-ignore
async function getUserKey(uid: string) {
  const keyDoc = await firestore.collection('keys').doc(uid).get();

  if (keyDoc.exists) {
    return kms.projects.locations.keyRings.cryptoKeys.decrypt({
      name: 'projects/igflexin-5d2db/locations/global/keyRings/igflexin/cryptoKeys/password',
      requestBody: {
        ciphertext: keyDoc.data()!['key']
      }
    }).then(async function (result) {
      return result.data.plaintext;
    });
  } else {
    const secureKey = hashString(uid, getRandomString(16));

    return kms.projects.locations.keyRings.cryptoKeys.encrypt({
      name: 'projects/igflexin-5d2db/locations/global/keyRings/igflexin/cryptoKeys/password',
      requestBody: {
        plaintext: Buffer.from(secureKey).toString('base64')
      }
    }).then(async function (result) {
      await admin.firestore().collection('keys').doc(uid).set({
        key: result.data.ciphertext
      });

      return Buffer.from(secureKey).toString('base64');
    });
  }
}

function hashString(string: string, salt: string) {
  const hash = crypto.createHmac('sha512', salt);
  hash.update(string);

  return hash.digest('hex');
}

function getRandomString(length: number) {
  return crypto.randomBytes(Math.ceil(length / 2)).toString('hex').slice(0, length);
}*/