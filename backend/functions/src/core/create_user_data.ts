import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

export default async function createUserData(data: any, context: CallableContext) {
  // Throw error if user is not authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  // User ID
  const uid = context.auth!.uid;

  // Try to get user data from database
  const userData = await admin.firestore().collection('users').doc(uid).get();

  let createNewData = false;

  if (userData.exists) {
    if (!userData.data()!.userCompleted) {
      createNewData = true;
    }
  } else {
    createNewData = true;
  }

  if (createNewData) {
    // Create user data
    await admin.firestore().collection('users').doc(uid).set({
      activeSubscription: { interval: 'none', type: 'none'},
      eligibleForFreeTrial: true,
      userCompleted: true
    });
  }
}