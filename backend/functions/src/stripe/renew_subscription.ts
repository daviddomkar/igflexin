import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as Stripe from 'stripe';
import { STRIPE_SECRET_KEY } from "../core/keys";

const stripe = new Stripe(STRIPE_SECRET_KEY);

export default async function renewSubscription(data: any, context: CallableContext) {

  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  const uid = context.auth!.uid;
  const userData = (await admin.firestore().collection('users').doc(uid).get()).data()!;
  const subscriptionId = userData.subscription.id;

  const subscription = await stripe.subscriptions.update(subscriptionId, {
    cancel_at_period_end: false,
  });

  await (await import('./update_subscription')).default(subscription);
}