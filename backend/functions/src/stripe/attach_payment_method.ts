import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as Stripe from 'stripe';
import { STRIPE_SECRET_KEY } from "../core/keys";

const stripe = new Stripe(STRIPE_SECRET_KEY);

export default async function attachPaymentMethod(data: any, context: CallableContext) {

  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  if (!data.paymentMethodId) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called with valid parameters.');
  }

  const uid = context.auth!.uid;
  const userData = (await admin.firestore().collection('users').doc(uid).get()).data()!;
  const subscriptionId = userData.subscription.id;

  const subscription = await stripe.subscriptions.update(subscriptionId, {
    // @ts-ignore
    default_payment_method: data.paymentMethodId,
  });

  await (await import('./update_subscription')).default(subscription);

  const subscriptionStatus = (await admin.firestore().collection('users').doc(uid).get()).data()!.subscription.status;

  return {
    requiresPayment:  subscriptionStatus === 'requires_payment_method',
  }
}