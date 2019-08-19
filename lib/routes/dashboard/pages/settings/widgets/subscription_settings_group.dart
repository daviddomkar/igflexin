import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class SubscriptionSettingsGroup extends StatefulWidget {
  SubscriptionSettingsGroup({Key key}) : super(key: key);

  @override
  _SubscriptionSettingsGroupState createState() {
    return _SubscriptionSettingsGroupState();
  }
}

class _SubscriptionSettingsGroupState extends State<SubscriptionSettingsGroup> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
      child: Container(
        margin: EdgeInsets.all(
          ResponsivityUtils.compute(20.0, context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subscription',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsivityUtils.compute(26.0, context),
                color: Colors.white,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: ResponsivityUtils.compute(320.0, context),
                  margin: EdgeInsets.only(
                      top: ResponsivityUtils.compute(10.0, context)),
                  child: CurvedWhiteBorderedTransparentButton(
                    child: Text(
                      'Upgrade or downgrade',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                Container(
                  width: ResponsivityUtils.compute(320.0, context),
                  child: CurvedWhiteBorderedTransparentButton(
                    child: Text(
                      'Apply coupon',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                Container(
                  width: ResponsivityUtils.compute(320.0, context),
                  child: CurvedWhiteBorderedTransparentButton(
                    child: Text(
                      'Manage payment methods',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                Container(
                  width: ResponsivityUtils.compute(320.0, context),
                  child: CurvedWhiteBorderedTransparentButton(
                    child: Text(
                      'Cancel subscription',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
