import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as Stripe from 'stripe';
import { STRIPE_SECRET_KEY } from "../core/keys";

const stripe = new Stripe(STRIPE_SECRET_KEY);

export default async function purchaseSubscription(data: any, context: CallableContext) {
  // Throw error if user is not authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  if (!data.paymentMethodId || !data.subscriptionType || !data.subscriptionInterval) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called with valid parameters.');
  }

  // User ID
  const uid = context.auth!.uid;

  // Try to get user data from database
  const userData = (await admin.firestore().collection('users').doc(uid).get()).data()!;
  const customerId = userData.customerId;
  const eligibleForFreeTrial = userData.eligibleForFreeTrial;
  const planId = (await admin.firestore().collection('system').doc('stripe').get()).data()!.plans_ids[data.subscriptionInterval][data.subscriptionType];

  const customer = await stripe.customers.retrieve(customerId);

  if (customer.subscriptions.total_count! > 0) {
    console.log('Fixing previous subscription');
    throw new functions.https.HttpsError('failed-precondition', 'Customer already has a purchased subscription.');
  } else {
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{
        plan: planId,
      }],
      expand: ['latest_invoice.payment_intent'],
      trial_period_days: eligibleForFreeTrial ? 7 : 0,
      // @ts-ignore
      payment_behavior: 'allow_incomplete',
      // @ts-ignore
      default_payment_method: data.paymentMethodId,
    });

    console.log(subscription);

    const subscriptionStatus = subscription.status;

    if (subscriptionStatus === 'trialing') {
      await admin.firestore().collection('users').doc(uid).update({
        subscription: {
          interval: data.subscriptionInterval,
          type: data.subscriptionType,
          trialEnds: subscription.trial_end,
        }
      });
    } else {
      const paymentIntentStatus = subscription.latest_invoice.payment_intent.status;

      if (subscriptionStatus === 'active' && paymentIntentStatus === 'succeeded') {
        await admin.firestore().collection('users').doc(uid).update({
          subscription: {
            interval: data.subscriptionInterval,
            type: data.subscriptionType,
          }
        });
      } else if (subscriptionStatus === 'incomplete' && paymentIntentStatus === 'requires_payment_method') {
        return {
          status: 'requires_payment_method',
        }
      } else if (subscriptionStatus === 'incomplete' && paymentIntentStatus === 'requires_action') {
        return {
          status: 'requires_action',
        }
      }
    }

    if (eligibleForFreeTrial) {
      await admin.firestore().collection('users').doc(uid).update({
        eligibleForFreeTrial: false,
      });
    }

    return {
      status: 'success',
    }
  }
}