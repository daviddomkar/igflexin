import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Auth functions
export const createUserData = functions.https.onCall(async (data, context) => {
  await (await import('./auth/create_user_data')).default(data, context);
});

// Stripe functions
export const createEphemeralKey = functions.https.onCall(async (data, context) => {
  return await (await import('./stripe/create_ephemeral_key')).default(data, context);
});

export const purchaseSubscription = functions.https.onCall(async (data, context) => {
  await (await import('./stripe/purchase_subscription')).default(data, context);
});

// Instagram functions
export const addAccount = functions.runWith({ memory: '512MB', timeoutSeconds: 120 }).https.onCall(async (data, context) => {
  await (await import('./instagram/add_account')).default(data, context);
});

export const processAccounts = functions.runWith({ memory: '2GB', timeoutSeconds: 480 }).pubsub.schedule('* * * * *').onRun(async () => {
  await (await import('./instagram/process_accounts')).default();
});