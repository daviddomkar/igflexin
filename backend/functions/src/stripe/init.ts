import * as admin from 'firebase-admin';
import * as Stripe from 'stripe';

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

  const plansToCreate = [];

  plansToCreate.push([
    stripe.plans.create({
      product: product.id,
      nickname: 'Monthly Basic Subscription',
      currency: 'gbp',
      interval: 'month',
      amount: 999,
    }),
    stripe.plans.create({
      product: product.id,
      nickname: 'Monthly Standard Subscription',
      currency: 'gbp',
      interval: 'month',
      amount: 1499,
    }),
    stripe.plans.create({
      product: product.id,
      nickname: 'Monthly Business Subscription',
      currency: 'gbp',
      interval: 'month',
      amount: 1999,
    }),
    stripe.plans.create({
      product: product.id,
      nickname: 'Monthly Business PRO Subscription',
      currency: 'gbp',
      interval: 'month',
      amount: 2999,
    }),
    stripe.plans.create({
      product: product.id,
      nickname: 'Yearly Basic Subscription',
      currency: 'gbp',
      interval: 'year',
      amount: 9999,
    }),
    stripe.plans.create({
      product: product.id,
      nickname: 'Yearly Standard Subscription',
      currency: 'gbp',
      interval: 'year',
      amount: 14999,
    }),
    stripe.plans.create({
      product: product.id,
      nickname: 'Yearly Business Subscription',
      currency: 'gbp',
      interval: 'year',
      amount: 19999,
    }),
    stripe.plans.create({
      product: product.id,
      nickname: 'Yearly Business PRO Subscription',
      currency: 'gbp',
      interval: 'year',
      amount: 29999,
    })
  ]);

  await Promise.all(plansToCreate);

  console.log('Init completed');
}