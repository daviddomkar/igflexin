import * as Stripe from "stripe";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {SubscriptionPlanInterval, SubscriptionPlanType} from "../types/subscription_plan";

export default async function initialSubscriptionPurchase(stripe: Stripe, uid: string, email: string | undefined, name: string | undefined, interval: SubscriptionPlanInterval, type: SubscriptionPlanType) {

  // Get user from Firestore database
  const user = await admin.firestore().collection('users/').doc(uid).get();

  // Variable to hold our customer
  let customer: Stripe.customers.ICustomer;

  // Checks if user already has assigned customer id
  if (user.exists && user.data() && user.data()!.hasOwnProperty('customer_id')) {
    // If true it retrieves customer data from Stripe
    customer = await stripe.customers.retrieve(user.data()!['customer_id']);

    // Check if customer has a subscription purchased already
    if (customer.subscriptions.total_count! > 0) {
      throw new functions.https.HttpsError('failed-precondition', 'Customer already has a purchased subscription.');
    }
  } else {
    // If false it creates new customer with our user's email and name
    customer = await stripe.customers.create({
      name: name,
      email: email
    });

    // Additionally it assigns created customer's id to our user in Firestore database
    await admin.firestore().collection('users').doc(uid).set({
      customer_id: customer.id
    }, {
      merge: true
    });
  }

  // Get plan id from Firestore database
  const systemStripe = await admin.firestore().collection('system').doc('stripe').get();

  console.log(systemStripe.data());

  const plan_id = systemStripe.data()!.plans_ids[interval][type];

  // Create subscription using selected plan id
  const subscription = await stripe.subscriptions.create({
    customer: customer.id,
    items: [{ plan: plan_id }],
    expand: ['latest_invoice.payment_intent']
  });

  console.log('Subscription created');
  console.log(subscription.latest_invoice!.payment_intent);
}