import 'package:flutter/material.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/subscription.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class SubscriptionInfo extends StatelessWidget {
  const SubscriptionInfo({Key key, this.subscription, this.onIconTap})
      : super(key: key);

  final Subscription subscription;
  final Function onIconTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          colors: [
            Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientStartColor,
            Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientEndColor
          ],
        ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsivityUtils.compute(8.0, context),
        vertical: ResponsivityUtils.compute(4.0, context),
      ),
      height: ResponsivityUtils.compute(120.0, context),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsivityUtils.compute(20.0, context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: ResponsivityUtils.compute(260.0, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getPrettyStringFromSubscriptionPlanType(subscription.type) +
                        ' plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsivityUtils.compute(26.0, context),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Next charge on 15th December 2019',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(14.0, context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              iconSize: ResponsivityUtils.compute(32.0, context),
              color: Colors.white,
              icon: Icon(Icons.settings),
              onPressed: () {
                onIconTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}
