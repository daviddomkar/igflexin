import * as admin from 'firebase-admin';
import {cloudkms_v1, google} from 'googleapis';
import * as cryptojs from "crypto-js";

const KMS_MANAGER_SERVICE_ACCOUNT_FILE = '../igflexin-5d2db-1b141234f3a2.json';
const IGFlexinKMSManagerServiceAccount = require(KMS_MANAGER_SERVICE_ACCOUNT_FILE);
const jwtKMSManagerClient = new google.auth.JWT(IGFlexinKMSManagerServiceAccount.client_email, KMS_MANAGER_SERVICE_ACCOUNT_FILE, IGFlexinKMSManagerServiceAccount.private_key, ['https://www.googleapis.com/auth/cloud-platform'], undefined, undefined);
const kms = new cloudkms_v1.Cloudkms({auth: jwtKMSManagerClient});

export default async function decryptPassword(uid: string, encryptedPassword: string): Promise<string> {

  const keyDoc = await admin.firestore().collection('keys').doc(uid).get();

  return kms.projects.locations.keyRings.cryptoKeys.decrypt({
    name: 'projects/igflexin-5d2db/locations/global/keyRings/igflexin/cryptoKeys/password',
    requestBody: {
      ciphertext: keyDoc.data()!.key
    }
  }).then(result => {
    const key = result.data.plaintext;

    return cryptojs.AES.decrypt(encryptedPassword, key!).toString(cryptojs.enc.Utf8);
  });
}