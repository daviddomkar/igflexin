import { CallableContext } from "firebase-functions/lib/providers/https";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as Stripe from 'stripe';
import { STRIPE_SECRET_KEY } from "../core/keys";

const stripe = new Stripe(STRIPE_SECRET_KEY);

export default async function createCustomer(data: any, context: CallableContext) {
  // Throw error if user is not authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  // User ID
  const uid = context.auth!.uid;

  // Get user data from database
  const userData = await admin.firestore().collection('users').doc(uid).get();

  if (!userData.data()!.customerId) {
    const customer = await stripe.customers.create({
      name: context.auth!.token!.name || undefined,
      email: context.auth!.token!.email || undefined
    });

    await admin.firestore().collection('users').doc(uid).set({
      customerId: customer.id
    }, {
      merge: true
    });
  }
}