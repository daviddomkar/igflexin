import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import { androidpublisher_v3, google } from "googleapis";

const settings = { timestampsInSnapshots: true };

const IGFlexinServiceAccount = {
    type: "service_account",
    project_id: "api-6280027237522613823-699584",
    private_key_id: "d5b3634d7acdf9e0252fbc495e8a73f5dba3744c",
    private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC8zWSmnEa47z5p\nNxnP1BVRaTvYjLjDH7T4ku7+YOmsmJFqZkd9sLzj6giRVjVx/p2XUPeD9aLWNKVn\n8jtIgGTplJlJ/Dns2TQomEvpfy/L/pn8yeJFudlv+40IirL3Ua4DpxYv30B/MaSx\nSOVsdqTaOpT/2k0gYEJO7DvZ9T4iJ9aoKvQOStOYsmDkJqDfFWr+WgIQyCoSH0oI\n29kELkhvpfJfTb3jy6etYDzcsMUML6KLBJG45KVPm6d/cB+8IbQdFsGLxGyiruaj\nwpx4V7KSFAqlSYsOiNKMh1NR9KKn83hrA6D/G71nqGrnwCuu08X4MWrjtz/DNkes\nHE10KrnVAgMBAAECggEAATSvDYuTEyqfjGrryEfnBvO+xRoQFj4MYCtfLO8sZ8TJ\nO6HzXrav6pbxDREEN3oNJg1AN27B2EF9JytaUcviyuHGL4RyFyZf+XWCNbeqHpf2\nrOoS8Ke6NI6NDtBaLc9LZuHnTSZNTtDfy2UskQpvm1ExkxWhDninzKV10GVSPQsm\nYHh9LhaWJ7S0PnA1MSyery6RsqciavcrePmDmmsU9rfhlUOkhSzdVaObuFB+H6FX\nhhosKES9riKk+nn2j/rlv65nDUV7pmuBlmxGJCQpNG9iN3WDY122eh18MsoaXrjs\nGTzF9CCOPaBVLm5w87SzwSNPajs6UwkiKKz1xntB9QKBgQD2BnRZpqzJ0Tm1t2+a\nrp02sWqbN1B4CyjmLBNwnEC/naUP+A9QFvUB50eNn8IWJPPR/Ux8Nz5PfdMUDmSS\nfOmrs46A29uLW9Q7htNlMpQPTVfzGkGJlJOsv2RFii57jQHeqTUDoSu+FZ3oazvS\n7lMQciColbYAS0wEitQMFk93YwKBgQDEdQK5/gQ8KVmTB7200Ca9j+xZZNE4ulp/\nOrW0oQB3EcaHC8T7muzl4/cY5JeQc1n2RVM17L8r5ZCTklAHvjlaoMILeJqjxAGa\npHXnkzAo6xPEhqStAn4cu2xB32AMo+fJxiq3ulJP8aoxsSTVkeQOCR43Z+lk9NCX\nPl0dWbDbZwKBgQCTwsKkiY9jUs7nTbmw3Ei97YaKnIku3/z7aONwEdhtfUACvEhu\nIKucLgzyiU3nQOBTcV87h25cDcT1WcObm3w4TIo86E8OfuOTsOFL+Tmlix1Ue6N6\n/wpGiViuz1QljkXeNiAKAwWjj5YcXjM69zpaOUFWHzyFJrQMUlkSvV+S4wKBgDnq\nJLuf3q+9oOJvTcWX91O6sfpIdkU66qLHM/nj3Lc9TkFRfuiNa3j6E0YLXYL//m1T\nUox7FoBiVJSsdVtTAKVu7sVi8HOGvNJR2VBDW9c0NcehyboXGgZuWiOxLieLyjD5\ncm5nRwy6OWocxrcPIyPgHEBJKczRPwzXHawhXLnRAoGABOSoK5C3G8yPRk06LWlm\nWfJERFC1JxZLsI8p2UyPy8y5wFdEJWLByXQbN//Wn9Kx8Ixi6Ufz/hqIADRhCUGa\n6gU8+WNzqk1zJHJI4geWCr/QFQRltEQaEVBZghLRBVp9nKw57ZEDLdVaSlmIaAU+\nUsMOm3DUKYg/Mc4MhXxEfPs=\n-----END PRIVATE KEY-----\n",
    client_email: "igflexin-purchase-manager@api-6280027237522613823-699584.iam.gserviceaccount.com",
    client_id: "100988672916871765060",
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/igflexin-purchase-manager%40api-6280027237522613823-699584.iam.gserviceaccount.com"
}

admin.initializeApp();
admin.firestore().settings(settings);

const jwtClient = new google.auth.JWT(IGFlexinServiceAccount.client_email, null, IGFlexinServiceAccount.private_key, ['https://www.googleapis.com/auth/androidpublisher'], null);
const androidPublisher = new androidpublisher_v3.Androidpublisher({ auth: jwtClient });

export const updateDisplayName = functions.https.onCall((data, context) => {
    if (!context.auth.uid || !data.displayName) return null;

    return admin.auth().updateUser(context.auth.uid, {
        displayName: data.displayName
    });
});

const SUBSCRIPTION_RECOVERED = 1; // TODO
const SUBSCRIPTION_RENEWED = 2;
const SUBSCRIPTION_CANCELED = 3; // TODO
const SUBSCRIPTION_PURCHASED = 4; // ! Handled in verifyGooglePlayPurchase function
const SUBSCRIPTION_ON_HOLD = 5; // TODO
const SUBSCRIPTION_IN_GRACE_PERIOD = 6; // TODO
const SUBSCRIPTION_RESTARTED = 7;
const SUBSCRIPTION_PRICE_CHANGE_CONFIRMED = 8;
const SUBSCRIPTION_DEFERRED = 9;

const PACKAGE_NAME = 'com.appapply.igflexin'

export const verifyGooglePlayPurchase = functions.https.onCall((data, context) => {
    if (!context.auth.uid || !data.subscriptionID || !data.token) throw new functions.https.HttpsError('invalid-argument', 'Parameters are not supplied.');

    return verifyGooglePlayPurchaseAsync(context.auth.uid, data.subscriptionID, data.token);

    /*
    return androidPublisher.purchases.subscriptions.get({
        packageName: 'com.appapply.igflexin',
        subscriptionId: data.subscriptionID,
        token: data.token
    }).then((response) => {
        return admin.firestore().collection('payments').where('userID', '==', context.auth.uid).limit(1).get().then((value) => {
            if (value.empty) {
                return admin.firestore().collection('payments').add({
                    type: 'GooglePlay',
                    subscriptionID: data.subscriptionID,
                    verified: true,
                    userID: context.auth.uid,
                    orderID: response.data.orderId,
                    purchaseToken: data.token
                }).then(() => {
                    return 'SUCCESS'
                });
            } else {
                return admin.firestore().collection('payments').doc(value.docs[0].id).update({
                    type: 'GooglePlay',
                    subscriptionID: data.subscriptionID,
                    verified: true,
                    userID: context.auth.uid,
                    orderID: response.data.orderId,
                    purchaseToken: data.token
                }).then(() => {
                    return 'SUCCESS'
                });
            }
        });


    }).catch((reason) => {
        return admin.firestore().collection('payments').add({
            type: 'GooglePlay',
            subscriptionID: data.subscriptionID,
            verified: false,
            userID: context.auth.uid,
            purchaseToken: data.token
        }).then(() => {
            throw new functions.https.HttpsError('not-found', 'Subscription is not verified.');
        }).catch(() => {
            throw new functions.https.HttpsError('not-found', 'Subscription is not verified.');
        })
    })*/
});

async function verifyGooglePlayPurchaseAsync(uid: string, subscriptionID: string, purchaseToken: string) {
    console.log("Verifying subscription for user: " + uid + " purchaseToken: " + purchaseToken + " subscriptionId: " + subscriptionID);
    try {
        const subscription = await androidPublisher.purchases.subscriptions.get({
            packageName: PACKAGE_NAME,
            subscriptionId: subscriptionID,
            token: purchaseToken
        });

        console.log(subscription.data);

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
                paymentState: subscription.data.paymentState
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
                paymentState: subscription.data.paymentState
            });
        }

        console.log("Subscription verified for user: " + uid + " purchaseToken: " + purchaseToken + " subscriptionId: " + subscriptionID);

        return 'SUCCESS';

    } catch(e) {

        try {
            const paymentDocument = await admin.firestore().collection('payments').where('userID', '==', uid).limit(1).get();

            if (paymentDocument.empty) {
                await admin.firestore().collection('payments').add({
                    type: 'GooglePlay',
                    subscriptionID: subscriptionID,
                    verified: false,
                    userID: uid,
                    purchaseToken: purchaseToken
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
                    paymentState: null
                });
            }
        } catch(e) {
            throw new functions.https.HttpsError('not-found', 'Subscription is not verified.');
        }

        throw new functions.https.HttpsError('not-found', 'Subscription is not verified.');
    }
}

export const playConsolePubSub = functions.pubsub.topic('PlayConsole').onPublish((message) => {

    const subscriptionNotification = message.json.subscriptionNotification;

    switch (subscriptionNotification.notificationType) {
        case SUBSCRIPTION_RECOVERED: {

            console.log("SUBSCRIPTION_RECOVERED" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            break;
        }
        case SUBSCRIPTION_RENEWED: {

            console.log("SUBSCRIPTION_RENEWED" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            break;
        }
        case SUBSCRIPTION_CANCELED: {

            console.log("SUBSCRIPTION_CANCELED" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            break;
        }
        case SUBSCRIPTION_PURCHASED: {

            console.log("SUBSCRIPTION_PURCHASED" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            // ! Should not be handled here. App is responsible for sending purchaseToken to verifyGooglePlayPurchase function

            break;
        }
        case SUBSCRIPTION_ON_HOLD: {

            console.log("SUBSCRIPTION_ON_HOLD" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            break;
        }
        case SUBSCRIPTION_IN_GRACE_PERIOD: {

            console.log("SUBSCRIPTION_IN_GRACE_PERIOD" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            break;
        }
        case SUBSCRIPTION_RESTARTED: {

            console.log("SUBSCRIPTION_RESTARTED" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            break;
        }
        case SUBSCRIPTION_PRICE_CHANGE_CONFIRMED: {

            console.log("SUBSCRIPTION_PRICE_CHANGE_CONFIRMED" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            break;
        }
        case SUBSCRIPTION_DEFERRED: {

            console.log("SUBSCRIPTION_DEFERRED" +
                " purchaseToken: " + subscriptionNotification.purchaseToken +
                " subscriptionId: " + subscriptionNotification.subscriptionId);

            break;
        }
    }
});