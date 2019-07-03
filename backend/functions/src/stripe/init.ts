import * as admin from 'firebase-admin';
import * as Stripe from 'stripe';
import {SubscriptionPlanInterval, SubscriptionPlanType} from '../types/subscription_plan';

export default async function init(stripe: Stripe) {
  const product = await stripe.products.create({
    name: 'IGFlexin Subscription',
    type: 'service'
  });

  await admin.firestore().collection('system').doc('stripe').set({
    product_id: product.id
  }, {
    merge: true
  });

  const planIDs: any = {};

  planIDs['month'] = {} as any;
  planIDs['year'] = {} as any;

  async function createPlan(interval: SubscriptionPlanInterval, type: SubscriptionPlanType) {
    const plan = await stripe.plans.create({
      product: product.id,
      nickname: ((): string => {
        switch (type) {
          case 'basic':
            return interval === 'month' ? 'Monthly Basic Subscription' : 'Yearly Basic Subscription';
          case 'standard':
            return interval === 'month' ? 'Monthly Standard Subscription' : 'Yearly Standard Subscription';
          case 'business':
            return interval === 'month' ? 'Monthly Business Subscription' : 'Yearly Business Subscription';
          case 'business_pro':
            return interval === 'month' ? 'Monthly Business PRO Subscription' : 'Yearly Business PRO Subscription';
        }
      })(),
      currency: 'gbp',
      interval: interval,
      amount: ((): number => {
        switch (type) {
          case 'basic':
            return interval === 'month' ? 999 : 9999;
          case 'standard':
            return interval === 'month' ? 1499 : 14999;
          case 'business':
            return interval === 'month' ? 1999 : 19999;
          case 'business_pro':
            return interval === 'month' ? 2999 : 29999;
        }
      })(),
    });

    planIDs[interval][type] = plan.id;
  }

  await createPlan('month', 'basic');
  await createPlan('month', 'standard');
  await createPlan('month', 'business');
  await createPlan('month', 'business_pro');
  await createPlan('year', 'basic');
  await createPlan('year', 'standard');
  await createPlan('year', 'business');
  await createPlan('year', 'business_pro');

  await admin.firestore().collection('system').doc('stripe').set({
    plans_ids: planIDs
  }, {
    merge: true
  });

  console.log('Init completed');
}