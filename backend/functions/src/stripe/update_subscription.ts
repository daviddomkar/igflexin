import * as admin from "firebase-admin";

import Timestamp = admin.firestore.Timestamp;

import * as Stripe from 'stripe';
import ISubscription = Stripe.subscriptions.ISubscription;
import { STRIPE_SECRET_KEY } from "../core/keys";

const stripe = new Stripe(STRIPE_SECRET_KEY);

export default async function updateSubscription(subscription: ISubscription) {
  await update(subscription);
}

async function update(subscriptionFromEvent: ISubscription) {
  console.log(subscriptionFromEvent);

  // @ts-ignore
  if (subscriptionFromEvent.status === 'past_due') {
    // @ts-ignore
    const subscription = await stripe.subscriptions.retrieve(subscriptionFromEvent.id, {
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

    if (subscription.latest_invoice!.payment_intent!.status === 'requires_payment_method') {
      await userReference.update({
        subscription: {
          id: subscription.id,
          status: 'requires_payment_method',
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
    } else if (subscription.latest_invoice!.payment_intent!.status === 'requires_action') {
      await userReference.update({
        subscription: {
          id: subscription.id,
          status: 'requires_action',
          interval: subscriptionData.interval,
          type: subscriptionData.type,
          trialEnds: subscription.trial_end !== null ? Timestamp.fromMillis(subscription.trial_end * 1000) : null,
          nextCharge: currentPeriodEnd,
          paymentIntentSecret: paymentIntentSecret,
          // @ts-ignore
          paymentMethodId: subscription.default_payment_method.id,
          // @ts-ignore
          paymentMethodBrand: subscription.default_payment_method.card.brand,
          // @ts-ignore
          paymentMethodLast4: subscription.default_payment_method.card.last4,
        }
      });
    }
  } else {
    // @ts-ignore
    if (subscriptionFromEvent.status !== 'incomplete_expired' && subscriptionFromEvent.status !== 'incomplete'  && subscriptionFromEvent.status !== 'canceled'  && subscriptionFromEvent.status !== 'unpaid') {
      // @ts-ignore
      const subscription = await stripe.subscriptions.retrieve(subscriptionFromEvent.id, {
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
  }
}