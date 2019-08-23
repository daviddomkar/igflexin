import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as Stripe from 'stripe';
import { STRIPE_SECRET_KEY } from "../core/keys";
import Timestamp = admin.firestore.Timestamp;

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

  await stripe.subscriptions.update(subscriptionId, {
    // @ts-ignore
    default_payment_method: data.paymentMethodId,
  });

  const subscription = await stripe.subscriptions.retrieve(subscriptionId, {
    expand: ['latest_invoice.payment_intent', 'default_payment_method'],
  });

  const planId = subscription.plan!.id;

  const subscriptionData = (await admin.firestore().collection('system').doc('stripe').collection('plans').doc(planId).get()).data()!;
  const userReference = (await admin.firestore().collection('users').where('customerId', '==', subscription.customer as string).limit(1).get()).docs[0].ref;

  let paymentIntentSecret = '';
  let currentPeriodEnd = Timestamp.fromMillis(0);

  try {
    paymentIntentSecret = subscription.latest_invoice!.payment_intent!.client_secret;
  } catch (e) {}

  try {
    currentPeriodEnd = Timestamp.fromMillis(subscription.current_period_end * 1000)
  } catch (e) {}

  let paymentMethodId = '';

  try {
    // @ts-ignore
    paymentMethodId = subscription.default_payment_method.id;
  } catch (e) {}

  let paymentMethodBrand = '';

  try {
    // @ts-ignore
    paymentMethodBrand = subscription.default_payment_method.card.brand;
  } catch (e) {}

  let paymentMethodLast4 = '';

  try {
    // @ts-ignore
    paymentMethodLast4 = subscription.default_payment_method.card.last4;
  } catch (e) {}
  // @ts-ignore
  await userReference.update({
    subscription: {
      id: subscription.id,
      status: subscription.cancel_at_period_end ? 'canceled' : 'active',
      interval: subscriptionData.interval,
      type: subscriptionData.type,
      trialEnds: subscription.trial_end !== null ? Timestamp.fromMillis(subscription.trial_end * 1000) : null,
      nextCharge: currentPeriodEnd,
      paymentIntentSecret: paymentIntentSecret,
      paymentMethodId: paymentMethodId,
      paymentMethodBrand: paymentMethodBrand,
      paymentMethodLast4: paymentMethodLast4,
    }
  });
}