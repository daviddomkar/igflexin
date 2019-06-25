export async function stripe(message: any) {
  // TODO Change to production key
  const stripeSecretKey = 'sk_test_ScPVsTjy2QAildXltrlHzJU900L0e1QTYz';
  const action: string = message.json.action;

  // tslint:disable-next-line:no-shadowed-variable
  const stripe = new (await import("stripe"))(stripeSecretKey);

  switch (action) {
    case 'init':
      await (await import('./init')).default(stripe);
      break;
    case 'dispose':
      await (await import('./dispose')).default(stripe);
      break;
    default:
      console.log('Invalid action');
      break;
  }
}
