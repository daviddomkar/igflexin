import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as Stripe from 'stripe';
import { STRIPE_SECRET_KEY } from "../core/keys";

const stripe = new Stripe(STRIPE_SECRET_KEY);

export default async function createEphemeralKey(data: any, context: CallableContext) {
  // Throw error if user is not authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  if (!data.apiVersion) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called with apiVersion parameter.');
  }

  // User ID
  const uid = context.auth!.uid;

  // Try to get user data from database
  const userData = await admin.firestore().collection('users').doc(uid).get();

  let customerId;

  // Create customer from user if required
  if (!userData.data()!.customerId) {
    await (await import('./create_customer')).default(data, context);
    customerId = (await admin.firestore().collection('users').doc(uid).get()).data()!.customerId
  } else {
    customerId = userData.data()!.customerId;
  }

  // Create ephemeral key
  const key = await stripe.ephemeralKeys.create({
    customer: customerId
  }, {
    stripe_version: data.apiVersion
  });

  console.log(key);

  // Send key back to client
  return key;
}