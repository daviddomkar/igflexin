import * as functions from 'firebase-functions';
import { CallableContext } from "firebase-functions/lib/providers/https";

// TODO Change to production key
const STRIPE_SECRET_KEY = 'sk_test_ScPVsTjy2QAildXltrlHzJU900L0e1QTYz';

export async function pubSub(message: any) {
  const stripe = new (await import("stripe"))(STRIPE_SECRET_KEY);
  const action: string = message.json.action;

  switch (action) {
    case 'init':
      await (await import('./init')).default(stripe);
      break;
    case 'dispose':
      await (await import('./dispose')).default(stripe);
      break;
    default:
      console.log('Invalid action');
      break;
  }
}

export async function initialSubscriptionPurchase(data: any, context: CallableContext) {
  if (!context.auth || !data.subscription_interval || !data.subscription_type) {
    throw new functions.https.HttpsError('failed-precondition', 'The function must be called while authenticated.');
  }

  // Store user information in fields for faster access
  const uid = context.auth!.uid;
  const email = context.auth!.token!.email || null; // Should never be null
  const name = context.auth!.token!.name || null;

  const subscription_interval: 'month' | 'year' = data.subscription_interval;
  const subscription_type: 'basic' | 'standard' | 'business' | 'business_pro' = data.subscription_type;

  const stripe = new (await import("stripe"))(STRIPE_SECRET_KEY);
  await (await import('./initial_subscription_purchase')).default(stripe, uid, email, name, subscription_interval, subscription_type);
}