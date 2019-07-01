import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:provider/provider.dart';

class SubscriptionPlanPaymentFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(Provider.of<SubscriptionRepository>(context).selectedPlanType);
    print(Provider.of<SubscriptionRepository>(context).selectedPlanInterval);

    return Center(
      child: Text('Ahoj hahahahhahaa'),
    );
  }
}
