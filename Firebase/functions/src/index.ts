import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

import { androidpublisher_v3, google, cloudkms_v1 } from 'googleapis';

const settings = { timestampsInSnapshots: true };

const PACKAGE_NAME = 'com.appapply.igflexin'

// ! These files are needed in lib directory. Currently, you have to manualy copy them because TypeScript compiler sucks
const PURCHASE_MANAGER_SERVICE_ACCOUNT_FILE = './api-6280027237522613823-699584-87cb07f2aecd.json';
const KMS_MANAGER_SERVICE_ACCOUNT_FILE = './igflexin-5d2db-1b141234f3a2.json';

const SUBSCRIPTION_RECOVERED = 1; // ! Not necessary because it would be used only if we had account on hold enabled which we have not.
const SUBSCRIPTION_RENEWED = 2;
const SUBSCRIPTION_CANCELED = 3; // TODO Delete subscription or mark as canceled - remove user entitlement, user can always restore it before it completely ends
const SUBSCRIPTION_PURCHASED = 4; // ! Handled in verifyGooglePlayPurchase function
const SUBSCRIPTION_ON_HOLD = 5; // ! Not enabled in Google Play Console
const SUBSCRIPTION_IN_GRACE_PERIOD = 6; // TODO Mark subscription is in grace period - warning will be displayed in app
const SUBSCRIPTION_RESTARTED = 7; // TODO Grant user entitlement - restarted after canceled
const SUBSCRIPTION_PRICE_CHANGE_CONFIRMED = 8; // * Not necessary until we want to change subscription prices
const SUBSCRIPTION_DEFERRED = 9; // * Not necessary - subscription will not trigger any other events if it is is deffered

const IGFlexinPurchaseManagerServiceAccount = require(PURCHASE_MANAGER_SERVICE_ACCOUNT_FILE);
const IGFlexinKMSManagerServiceAccount = require(KMS_MANAGER_SERVICE_ACCOUNT_FILE);

admin.initializeApp();
admin.firestore().settings(settings);

const jwtPurchaseManagerClient = new google.auth.JWT(IGFlexinPurchaseManagerServiceAccount.client_email, PURCHASE_MANAGER_SERVICE_ACCOUNT_FILE, IGFlexinPurchaseManagerServiceAccount.private_key, ['https://www.googleapis.com/auth/androidpublisher'], null, null)
const jwtKMSManagerClient = new google.auth.JWT(IGFlexinKMSManagerServiceAccount.client_email, KMS_MANAGER_SERVICE_ACCOUNT_FILE, IGFlexinKMSManagerServiceAccount.private_key, ['https://www.googleapis.com/auth/cloud-platform'], null, null)

const androidPublisher = new androidpublisher_v3.Androidpublisher({ auth: jwtPurchaseManagerClient });
const kms = new cloudkms_v1.Cloudkms({ auth: jwtKMSManagerClient });

/* 

* JUST IGNORE THIS DOG PLEASE. IT MAKES ME THINK FASTER. :3 *

░░░░░░░░░░░▄▀▄▀▀▀▀▄▀▄░░░░░░░░░░░░░░░░░░
░░░░░░░░░░░█░░░░░░░░▀▄░░░░░░▄░░░░░░░░░░
░░░░░░░░░░█░░▀░░▀░░░░░▀▄▄░░█░█░░░░░░░░░
░░░░░░░░░░█░▄░█▀░▄░░░░░░░▀▀░░█░░░░░░░░░
░░░░░░░░░░█░░▀▀▀▀░░░░░░░░░░░░█░░░░░░░░░
░░░░░░░░░░█░░░░░░░░░░░░░░░░░░█░░░░░░░░░
░░░░░░░░░░█░░░░░░░░░░░░░░░░░░█░░░░░░░░░
░░░░░░░░░░░█░░▄▄░░▄▄▄▄░░▄▄░░█░░░░░░░░░░
░░░░░░░░░░░█░▄▀█░▄▀░░█░▄▀█░▄▀░░░░░░░░░░
░░░░░░░░░░░░▀░░░▀░░░░░▀░░░▀░░░░░░░░░░░░

* IT ACTUALLY FIXED MY CODE *

*/

export const updateDisplayName = functions.https.onCall((data, context) => {
    if (!context.auth.uid || !data.displayName) return null;

    return admin.auth().updateUser(context.auth.uid, {
        displayName: data.displayName
    });
});

export const createUserKey = functions.https.onCall((data, context) => {
    if (!context.auth.uid) throw new functions.https.HttpsError('invalid-argument', 'Parameters are not supplied.');

    return createUserKeyAsync(context.auth.uid);
});

async function createUserKeyAsync(uid: string) {
    const keyFromDB = await admin.firestore().collection('keys').doc(uid).get()

    if (keyFromDB.exists && keyFromDB.data().key) {
        return keyFromDB.data().key as string;
    } else {
        const secureKey = hashString(uid, getRandomString(16));
    
        return kms.projects.locations.keyRings.cryptoKeys.encrypt({
            name: 'projects/igflexin-5d2db/locations/global/keyRings/igflexin/cryptoKeys/password',
            requestBody: {
                plaintext: Buffer.from(secureKey).toString('base64')
            }
        }).then(async function(result) {
            await admin.firestore().collection('keys').doc(uid).set({
                key: result.data.ciphertext
            });
    
            return result.data.ciphertext;
        });
    }
}

function hashString(string: string, salt: string) {
    const hash = crypto.createHmac('sha512', salt);
    hash.update(string);

    const value = hash.digest('hex');

    return value;
}

function getRandomString(length: number) {
    return crypto.randomBytes(Math.ceil(length/2)).toString('hex').slice(0,length);
}

export const decryptUserKey = functions.https.onCall((data, context) => {
    if (!context.auth.uid || !data.key) throw new functions.https.HttpsError('invalid-argument', 'Parameters are not supplied.');

    return decryptUserKeyAsync(context.auth.uid, data.key);
});

async function decryptUserKeyAsync(uid: string, key: string) {
    const keyFromDB = await admin.firestore().collection('keys').doc(uid).get()

    if (keyFromDB.exists && keyFromDB.data().key && keyFromDB.data().key === key) {
        return kms.projects.locations.keyRings.cryptoKeys.decrypt({
            name: 'projects/igflexin-5d2db/locations/global/keyRings/igflexin/cryptoKeys/password',
            requestBody: {
                ciphertext: key
            }
        }).then(async function(result) {
            return result.data.plaintext;
        });
    } else {
        throw new functions.https.HttpsError('not-found', 'Key does not exists.');
    }
}

export const verifyGooglePlayPurchase = functions.https.onCall((data, context) => {
    if (!context.auth.uid || !data.subscriptionID || !data.token) throw new functions.https.HttpsError('invalid-argument', 'Parameters are not supplied.');

    const uid = context.auth.uid;
    const subscriptionID = data.subscriptionID;
    const purchaseToken = data.token;

    console.log('Verifying subscription for user: ' + uid + ' purchaseToken: ' + purchaseToken + ' subscriptionId: ' + subscriptionID);

    return androidPublisher.purchases.subscriptions.get({
        packageName: PACKAGE_NAME,
        subscriptionId: subscriptionID,
        token: purchaseToken
    }).then(async function(subscription) {
        console.log(subscription.data);

        // TODO probably convert it to update somehow to prevent deleting
        if (subscription.data.linkedPurchaseToken) {
            try {
                const oldSubscription =  await admin.firestore().collection('payments').where('purchaseToken', '==', subscription.data.linkedPurchaseToken).limit(1).get();
                await admin.firestore().collection('payments').doc(oldSubscription.docs[0].id).delete();
            } catch(e) {
                console.log('ERROR DELETING OLD SUBSCRIPTION ' + subscription.data.linkedPurchaseToken);
            }
        }

        const paymentDocument = await admin.firestore().collection('payments').where('userID', '==', uid).limit(1).get();

        if (paymentDocument.empty) {
            await admin.firestore().collection('payments').add({
                type: 'GooglePlay',
                subscriptionID: subscriptionID,
                verified: true,
                userID: uid,
                orderID: subscription.data.orderId,
                purchaseToken: purchaseToken,
                autoRenewing: subscription.data.autoRenewing,
                paymentState: subscription.data.paymentState,
                lastTimeRenewed: Date.now(),
                inGracePeriod: false,
            });
        } else {
            await admin.firestore().collection('payments').doc(paymentDocument.docs[0].id).update({
                type: 'GooglePlay',
                subscriptionID: subscriptionID,
                verified: true,
                userID: uid,
                orderID: subscription.data.orderId,
                purchaseToken: purchaseToken,
                autoRenewing: subscription.data.autoRenewing,
                paymentState: subscription.data.paymentState,
                lastTimeRenewed: Date.now(),
                inGracePeriod: false
            });
        }

        console.log('Subscription verified for user: ' + uid + ' purchaseToken: ' + purchaseToken + ' subscriptionId: ' + subscriptionID);

        return 'SUCCESS';

    }).catch(async function(err) {
        console.log('ERROR');
        console.log(err);

        try {
            const paymentDocument = await admin.firestore().collection('payments').where('userID', '==', uid).limit(1).get();

            if (paymentDocument.empty) {
                await admin.firestore().collection('payments').add({
                    type: 'GooglePlay',
                    subscriptionID: subscriptionID,
                    verified: false,
                    userID: uid,
                    purchaseToken: purchaseToken,
                    autoRenewing: null,
                    paymentState: null,
                    lastTimeRenewed: null,
                    inGracePeriod: null
                });
            } else {
                await admin.firestore().collection('payments').doc(paymentDocument.docs[0].id).update({
                    type: 'GooglePlay',
                    subscriptionID: subscriptionID,
                    verified: false,
                    userID: uid,
                    orderID: null,
                    purchaseToken: purchaseToken,
                    autoRenewing: null,
                    paymentState: null,
                    lastTimeRenewed: null,
                    inGracePeriod: null
                });
            }
        } catch(e) {
            throw new functions.https.HttpsError('not-found', 'Subscription is not verified.');
        }

        throw new functions.https.HttpsError('not-found', 'Subscription is not verified.');
    });
});

export const playConsolePubSub = functions.pubsub.topic('PlayConsole').onPublish((message) => {

    const subscriptionNotification = message.json.subscriptionNotification;

    switch (subscriptionNotification.notificationType) {
        case SUBSCRIPTION_RENEWED: {

            const subscriptionID = subscriptionNotification.subscriptionId;
            const purchaseToken = subscriptionNotification.purchaseToken;

            console.log('SUBSCRIPTION_RENEWED' +' purchaseToken: ' + purchaseToken + ' subscriptionId: ' + subscriptionID);

            return androidPublisher.purchases.subscriptions.get({
                packageName: PACKAGE_NAME,
                subscriptionId: subscriptionID,
                token: purchaseToken
            }).then(async function(subscription) {
                const payment = await admin.firestore().collection('payments').where('purchaseToken', '==', purchaseToken).limit(1).get();

                console.log(subscription.data);

                if (purchaseToken !== subscription.data.linkedPurchaseToken) {
                    try {
                        const oldPayment = await admin.firestore().collection('payments').where('purchaseToken', '==', subscription.data.linkedPurchaseToken).limit(1).get();
                        await admin.firestore().collection('payments').doc(oldPayment.docs[0].id).delete();
                    } catch(e) {
            
                    }
                }

                await admin.firestore().collection('payments').doc(payment.docs[0].id).update({
                    inGracePeriod: false,
                    orderID: subscription.data.orderId,
                    lastTimeRenewed: Date.now()
                });
            });
        }
        case SUBSCRIPTION_CANCELED: {

            const subscriptionID = subscriptionNotification.subscriptionId;
            const purchaseToken = subscriptionNotification.purchaseToken;

            console.log('SUBSCRIPTION_CANCELED' + ' purchaseToken: ' + purchaseToken + ' subscriptionId: ' + subscriptionID);

            return androidPublisher.purchases.subscriptions.get({
                packageName: PACKAGE_NAME,
                subscriptionId: subscriptionID,
                token: purchaseToken
            }).then(async function(subscription) {
                const payment = await admin.firestore().collection('payments').where('purchaseToken', '==', purchaseToken).limit(1).get();

                console.log(subscription.data);

                if (purchaseToken !== subscription.data.linkedPurchaseToken) {
                    try {
                        const oldPayment = await admin.firestore().collection('payments').where('purchaseToken', '==', subscription.data.linkedPurchaseToken).limit(1).get();
                        await admin.firestore().collection('payments').doc(oldPayment.docs[0].id).delete();
                    } catch(e) {
        
                    }
                }

                if (subscription.data.autoRenewing === false && !subscription.data.paymentState) {
                    await admin.firestore().collection('payments').doc(payment.docs[0].id).delete();
                } else {
                    await admin.firestore().collection('payments').doc(payment.docs[0].id).update({
                        autoRenewing: subscription.data.autoRenewing,
                        paymentState: subscription.data.paymentState,
                        inGracePeriod: false
                    });
                }

            }).catch(async function(err) {
                const payment = await admin.firestore().collection('payments').where('purchaseToken', '==', purchaseToken).limit(1).get();
                await admin.firestore().collection('payments').doc(payment.docs[0].id).delete();
            });
        }
        case SUBSCRIPTION_IN_GRACE_PERIOD: {

            const subscriptionID = subscriptionNotification.subscriptionId;
            const purchaseToken = subscriptionNotification.purchaseToken;

            console.log('SUBSCRIPTION_IN_GRACE_PERIOD' + ' purchaseToken: ' + purchaseToken + ' subscriptionId: ' + subscriptionID);

            return (async function() {
                const payment = await admin.firestore().collection('payments').where('purchaseToken', '==', purchaseToken).limit(1).get();

                await admin.firestore().collection('payments').doc(payment.docs[0].id).update({
                    inGracePeriod: true
                });
            })();
        }
        case SUBSCRIPTION_RESTARTED: {

            const subscriptionID = subscriptionNotification.subscriptionId;
            const purchaseToken = subscriptionNotification.purchaseToken;

            console.log('SUBSCRIPTION_RESTARTED' + ' purchaseToken: ' + purchaseToken + ' subscriptionId: ' + subscriptionID);

            return androidPublisher.purchases.subscriptions.get({
                packageName: PACKAGE_NAME,
                subscriptionId: subscriptionID,
                token: purchaseToken
            }).then(async function(subscription) {
                const payment = await admin.firestore().collection('payments').where('purchaseToken', '==', purchaseToken).limit(1).get();

                console.log(subscription.data);

                if (purchaseToken !== subscription.data.linkedPurchaseToken) {
                    try {
                        const oldPayment = await admin.firestore().collection('payments').where('purchaseToken', '==', subscription.data.linkedPurchaseToken).limit(1).get();
                        await admin.firestore().collection('payments').doc(oldPayment.docs[0].id).delete();
                    } catch(e) {
            
                    }
                }
            
                await admin.firestore().collection('payments').doc(payment.docs[0].id).update({
                    autoRenewing: subscription.data.autoRenewing,
                    paymentState: subscription.data.paymentState,
                    inGracePeriod: false
                });
            });
        }
        default: {
            return null;
        }
    }
});
