import * as admin from 'firebase-admin';
import { https, runWith } from "firebase-functions";

import app from "./stripe/webhook";

admin.initializeApp();

// Auth functions
export const createUserData = https.onCall(async (data, context) => {
  await (await import('./auth/create_user_data')).default(data, context);
});

// Stripe functions
export const createEphemeralKey = https.onCall(async (data, context) => {
  return await (await import('./stripe/create_ephemeral_key')).default(data, context);
});

export const purchaseSubscription = https.onCall(async (data, context) => {
  return await (await import('./stripe/purchase_subscription')).default(data, context);
});

export const webhook = https.onRequest(app);

// Instagram functions
export const addAccount = runWith({ memory: '512MB', timeoutSeconds: 120 }).https.onCall(async (data, context) => {
  return await (await import('./instagram/add_account')).default(data, context);
});

export const editAccount = runWith({ memory: '512MB', timeoutSeconds: 120 }).https.onCall(async (data, context) => {
  return await (await import('./instagram/edit_account')).default(data, context);
});

export const sendSecurityCode =https.onCall(async (data, context) => {
  return await (await import('./instagram/send_security_code')).default(data, context);
});

export const sendTwoFactorAuthCode = https.onCall(async (data, context) => {
  return await (await import('./instagram/send_two_factor_auth_code')).default(data, context);
});

export const processAccounts = runWith({ memory: '2GB', timeoutSeconds: 480 }).pubsub.schedule('* * * * *').onRun(async () => {
  await (await import('./instagram/process_accounts')).default();
});
