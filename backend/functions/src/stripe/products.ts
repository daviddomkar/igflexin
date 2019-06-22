export async function stripe(message: any) {
  const action: string = message.json.action;

  // TODO Change to production key
  // tslint:disable-next-line:no-shadowed-variable
  const stripe = new (await import("stripe"))('sk_test_ScPVsTjy2QAildXltrlHzJU900L0e1QTYz');

  switch (action) {
    case 'init':
      await init();
      break;
    default:
      console.log('Invalid action');
      break;
  }

  async function init() {
    const product = await stripe.products.create({
      name: 'IGFlexin Subscription',
      type: 'service'
    });

    const plans = [];

    plans.push([
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

    await Promise.all(plans);

    console.log('Initialization completed');
  }
}

