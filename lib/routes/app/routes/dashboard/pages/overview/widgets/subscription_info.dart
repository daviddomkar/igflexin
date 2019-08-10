import 'package:flutter/material.dart';
import 'package:igflexin/resources/subscription.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

class SubscriptionInfo extends StatelessWidget {
  const SubscriptionInfo({Key key, this.subscription}) : super(key: key);

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsivityUtils.compute(8.0, context),
        vertical: ResponsivityUtils.compute(4.0, context),
      ),
      height: ResponsivityUtils.compute(120.0, context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Column(
            children: [Text(subscription.type.toString())],
          ),
        ],
      ),
    );
  }
}
