import * as express from "express";
import * as admin from "firebase-admin";
import Timestamp = admin.firestore.Timestamp;

const app = express();

app.post('/', async (req, res) => {
  const STRIPE_SECRET_KEY = (await import('../core/keys')).STRIPE_SECRET_KEY;
  const Stripe = await import('stripe');

  const stripe = new Stripe(STRIPE_SECRET_KEY);

  const webhookSecret = 'whsec_9jjjwBoDEJbc3hSL9EU0icW0RwTzyUiu';//'whsec_wk5CPXDNOKKsnSF7y9cFEUz1xQIHrSOh';
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
    const subscriptionEvent = event.data.object;

    console.log(subscriptionEvent);

    // @ts-ignore
    if (subscriptionEvent.status === 'past_due') {
      // @ts-ignore
      const subscription = await stripe.subscriptions.retrieve(subscriptionEvent.id, {
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
      if (subscriptionEvent.status !== 'incomplete_expired' && subscriptionEvent.status !== 'incomplete'  && subscriptionEvent.status !== 'canceled'  && subscriptionEvent.status !== 'unpaid') {
        // @ts-ignore
        const subscription = await stripe.subscriptions.retrieve(subscriptionEvent.id, {
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