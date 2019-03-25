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

* JUST IGNORE THIS DOG PLEASE *
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
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
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
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

export const instagramPubSub = functions.pubsub.topic('Instagram').onPublish((message) => {

    console.log("Sending FCM");

    return admin.messaging().sendToTopic("Instagram", {
        data: {
            instagram: "check"
        }
    })
});

export const canRunWorker = functions.https.onCall((data, context) => {
    if (!context.auth.uid) throw new functions.https.HttpsError('invalid-argument', 'Parameters are not supplied.');

    return canRunWorkerAsync(context.auth.uid);
});

async function canRunWorkerAsync(uid: string) {
    const userData = await admin.firestore().collection('users').doc(uid).get()

    if (userData.exists && userData.data().lastAction) {

        const last = userData.data().lastAction.toMillis();

        if (last + 1000 * 60 * 20 < admin.firestore.Timestamp.fromDate(new Date()).toMillis()) {
            await admin.firestore().collection('users').doc(uid).set({
                lastAction: admin.firestore.FieldValue.serverTimestamp()
            });

            return 'SUCCESS';
        } else {
            throw new functions.https.HttpsError('permission-denied', 'Too early to run progress');
        }

    } else {
        await admin.firestore().collection('users').doc(uid).set({
            lastAction: admin.firestore.FieldValue.serverTimestamp()
        });

        return 'SUCCESS';
    }
}

export const updateAccountEntitlementUponSubscriptionChange = functions.firestore.document('payments/{id}').onUpdate((change, context) => {

    const data = change.after.data();
    const previousData = change.before.data();

    if (data.subscriptionID === previousData.subscriptionID) return null;

    return updateAccountEntitlementUponSubscriptionChangeAsync(data.userID, data.subscriptionID);
});

export const updateAccountEntitlementUponSubscriptionCreation = functions.firestore.document('payments/{id}').onCreate((change, context) => {

    const data = change.data();

    return updateAccountEntitlementUponSubscriptionChangeAsync(data.userID, data.subscriptionID);
});

async function updateAccountEntitlementUponSubscriptionChangeAsync(uid: string, subscriptionID: string) {
    const accounts = await admin.firestore().collection('accounts').where('userID', '==', uid).get();

    let maxAccounts = 1;

    if (subscriptionID.includes("standard")) {
        maxAccounts = 3;
    } else if (subscriptionID.includes("business_pro")) {
        maxAccounts = 10;
    } else if (subscriptionID.includes("business")) {
        maxAccounts = 5;
    }

    for (const account of accounts.docs) {

        if(maxAccounts <= 0) {
            await admin.firestore().collection('accounts').doc(account.id).update({
                status: 'low_subscription'
            });
        } else {
            if (account.data().status === 'low_subscription' || account.data().status === 'requirements_not_met') {
                await admin.firestore().collection('accounts').doc(account.id).update({
                    status: 'running'
                });
            }
        }

        maxAccounts--;
    }
}

export const recordStats = functions.https.onCall((data, context) => {
    if (!context.auth.uid || !data.id || !data.followers) throw new functions.https.HttpsError('invalid-argument', 'Parameters are not supplied.');

    return recordStatsAsync(context.auth.uid, data.id, data.followers);
});

async function recordStatsAsync(uid: string, id: number, newFollowers: number) {

    await admin.firestore().runTransaction(async (transaction) => {
        const account = await transaction.get(admin.firestore().collection('accounts').where('id', '==', id).limit(1));

        if (account.docs.length > 0 && account.docs[0].data().userID === uid) {

            const statistics = await transaction.get(admin.firestore().collection('statistics').doc(account.docs[0].id));

            function computeNewArrayOfStatsRecord(array: Array<number | null>, lastAction: Date, followers: number, diffMilisecondsComputeDivisionFunction: (diff: number) => number): { array: Array<number | null>, newLastAction: boolean } {

                const date = new Date();

                let lastIndex = array.indexOf(null);
            
                if (lastIndex === -1) {
                    lastIndex = array.length;
                }

                lastIndex -= 1;
            
                const diff = Math.round(diffMilisecondsComputeDivisionFunction(date.getTime() - lastAction.getTime()));
            
                const newLastAction = diff > 0;
            
                if (lastIndex + diff > array.length - 1) {
                    const shift = ((lastIndex + diff) % array.length) + 1;
                    array.splice(0, shift);
                    lastIndex += (diff - shift);
                    for (let i = 0; i < shift; i++) {
                        array.push(null);

                        if (array.length > 23) {
                            break;
                        }
                    }
                } else {
                    lastIndex += diff
                }

                if (diff > array.length - 1) {
                    lastIndex = 0;
                }

                for (let i = 0; i < lastIndex; i++) {
                    if (array[i] === null) {
                        array[i] = followers;
                    }
                }

                if (array[lastIndex] !== null) {
                    array[lastIndex] = (array[lastIndex] + followers) / 2;
                } else {
                    array[lastIndex] = followers;
                }

                return {
                    array: array,
                    newLastAction: newLastAction
                }
            }

            if (statistics.exists) {
                const lastAction = (statistics.data().lastAction as FirebaseFirestore.Timestamp).toDate();

                const hours_of_day = statistics.data().hours_of_day as Array<number | null>;
                const days_of_week = statistics.data().days_of_week as Array<number | null>;
                const days_of_month = statistics.data().days_of_month as Array<number | null>;

                const hours_of_day_result = computeNewArrayOfStatsRecord(hours_of_day, lastAction, newFollowers, (diff) => {
                    return diff / 1000 / 60 / 60;
                });

                const days_of_week_result = computeNewArrayOfStatsRecord(days_of_week, lastAction, newFollowers, (diff) => {
                    return diff / 1000 / 60 / 60 / 24;
                });

                const days_of_month_result = computeNewArrayOfStatsRecord(days_of_month, lastAction, newFollowers, (diff) => {
                    return diff / 1000 / 60 / 60 / 24;
                });

                if (days_of_month_result.newLastAction) {
                    await transaction.update(admin.firestore().collection('statistics').doc(account.docs[0].id), {
                        lastAction: admin.firestore.FieldValue.serverTimestamp(),
                        hours_of_day: hours_of_day_result.array,
                        days_of_week: days_of_week_result.array,
                        days_of_month: days_of_month_result.array
                    });
                } else {
                    await transaction.update(admin.firestore().collection('statistics').doc(account.docs[0].id), {
                        hours_of_day: hours_of_day_result.array,
                        days_of_week: days_of_week_result.array,
                        days_of_month: days_of_month_result.array
                    });
                }

            } else {
                await transaction.set(admin.firestore().collection('statistics').doc(account.docs[0].id), {
                    lastAction: admin.firestore.FieldValue.serverTimestamp(),
                    hours: [
                        newFollowers, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null
                    ],
                    days_of_week: [
                        newFollowers, null, null, null, null, null, null
                    ],
                    days_of_month: [
                        newFollowers, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null
                    ]
                });
            }
        }
    });
}