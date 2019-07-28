import * as admin from "firebase-admin";
import Timestamp = admin.firestore.Timestamp;
import {SubscriptionPlanType} from "../types/subscription_plan";

export default async function processAccounts(uid: string | undefined) {

  if (!uid) {
    const users = await admin.firestore().collection('users').where('lastAction', '<',  Timestamp.fromMillis(Timestamp.now().toMillis() - 1000 * 60 * 20)).where('lastAction', '==', null).get();

    if (users.empty) {
      return;
    }

    for (const user of users.docs) {
      if (user.data().subscription) {
        const subscription = user.data().subscription;

        let maxInstagramAccounts = 0;

        const type: SubscriptionPlanType = subscription.type;

        switch (type) {
          case "basic":
            maxInstagramAccounts = 1;
            break;
          case "standard":
            maxInstagramAccounts = 3;
            break;
          case "business":
            maxInstagramAccounts = 5;
            break;
          case "business_pro":
            maxInstagramAccounts = 10;
            break;
        }

        const accounts = await admin.firestore().collection('users').doc(user.id).collection('accounts').get();

        let index = 0;

        for (const account of accounts.docs) {
          


          index++;
        }

        //
      }
    }
  }
}

async function processAccount(account: any) {

}