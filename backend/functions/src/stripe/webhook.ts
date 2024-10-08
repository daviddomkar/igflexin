import * as express from "express";
import * as admin from "firebase-admin";
import Timestamp = admin.firestore.Timestamp;
import * as Stripe from "stripe";
import ISubscription = Stripe.subscriptions.ISubscription;

const app = express();

app.post('/', async (req, res) => {
  const STRIPE_SECRET_KEY = (await import('../core/keys')).STRIPE_SECRET_KEY;
  const Stripe = await import('stripe');

  const stripe = new Stripe(STRIPE_SECRET_KEY);

  const webhookSecret = '';
  const sig = req.headers['stripe-signature'];

  let event;

  try {
    // @ts-ignore
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    // On error, return the error message
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Do something with event
  console.log('Success:', event.id);

  if (event.type === 'invoice.payment_succeeded') {
    const invoice = event.data.object;
    // @ts-ignore
    if (invoice.billing_reason === 'subscription_create') {
      // @ts-ignore
      const subscription = await stripe.subscriptions.retrieve(invoice.subscription as string, {
        expand: ['latest_invoice.payment_intent', 'default_payment_method'],
      });

      const planId = subscription.plan!.id;

      const subscriptionData = (await admin.firestore().collection('system').doc('stripe').collection('plans').doc(planId).get()).data()!;
      const userReference = (await admin.firestore().collection('users').where('customerId', '==', subscription.customer as string).limit(1).get()).docs[0].ref;

      let paymentIntentSecret = '';

      try {
        paymentIntentSecret = subscription.latest_invoice!.payment_intent!.client_secret;
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
          status: 'active',
          interval: subscriptionData.interval,
          type: subscriptionData.type,
          trialEnds: subscription.trial_end !== null ? Timestamp.fromMillis(subscription.trial_end * 1000) : null,
          nextCharge: Timestamp.fromMillis(subscription.current_period_end * 1000),
          paymentIntentSecret: paymentIntentSecret,
          paymentMethodId: paymentMethodId,
          paymentMethodBrand: paymentMethodBrand,
          paymentMethodLast4: paymentMethodLast4,
        }
      });
    }
  } else if (event.type === 'customer.subscription.updated') {
    await (await import('./update_subscription')).default(event.data.object as ISubscription);
  } else if (event.type === 'customer.subscription.deleted') {
    const subscription = event.data.object;

    // @ts-ignore
    const userReference = (await admin.firestore().collection('users').where('customerId', '==', subscription.customer as string).limit(1).get()).docs[0].ref;

    await userReference.update({
      subscription: null,
    });
  }

  // Return a response to acknowledge receipt of the event
  return res.json({received: true});
});

export default app;