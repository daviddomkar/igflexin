import * as admin from 'firebase-admin';
import * as Stripe from 'stripe';

export default async function dispose(stripe: Stripe) {
  const product = await stripe.products.retrieve((await admin.firestore().collection('system').doc('stripe').get()).data()!!['product_id']);
  const plans = await stripe.plans.list({
    product: product.id
  });

  const plansToDelete = [];

  for (const plan of plans.data) {
    plansToDelete.push(
      stripe.plans.del(plan.id)
    );
  }

  await Promise.all(plansToDelete);
  await stripe.products.del(product.id);
  await admin.firestore().collection('system').doc('stripe').delete();

  console.log('Dispose completed');
}