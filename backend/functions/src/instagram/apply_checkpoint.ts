import { CallableContext } from "firebase-functions/lib/providers/https";
import * as functions from "firebase-functions";

export default async function applyCheckpoint(data: any, context: CallableContext) {

  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  if (!data.code || !data.phoneNumber) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called with required parameters.');
  }
}