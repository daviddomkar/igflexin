import 'package:flutter/material.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';
import 'package:igflexin/resources/user.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class Summary extends StatefulWidget {
  Summary({Key key, @required this.controller})
      : opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        offsetY = Tween(begin: 15.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> opacity;
  final Animation<double> offsetY;

  @override
  _SummaryState createState() {
    return _SummaryState();
  }
}

class _SummaryState extends State<Summary> {
  SubscriptionRepository _subscriptionRepository;
  UserRepository _userRepository;

  bool _eligibleForFreeTrial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _userRepository = Provider.of<UserRepository>(context);

    if (_userRepository.user.state == UserState.Authenticated) {
      _eligibleForFreeTrial = _userRepository.user.data.eligibleForFreeTrial;
    }
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    SubscriptionPlan plan = SubscriptionPlan(_subscriptionRepository.selectedPlanType);

    return Transform.translate(
      offset: Offset(0.0, widget.offsetY.value),
      child: Opacity(
        opacity: widget.opacity.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_eligibleForFreeTrial) ...{
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsivityUtils.compute(6.0, context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'First 7 days:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(18.0, context),
                      ),
                    ),
                    Text(
                      'FREE',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(18.0, context),
                      ),
                    ),
                  ],
                ),
              ),
            },
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: ResponsivityUtils.compute(6.0, context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _eligibleForFreeTrial ? 'Then for:' : 'For:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsivityUtils.compute(18.0, context),
                    ),
                  ),
                  Text(
                    _subscriptionRepository.selectedPlanInterval == SubscriptionPlanInterval.Month
                        ? plan.monthlyPrice
                        : plan.yearlyPrice,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: ResponsivityUtils.compute(18.0, context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: ResponsivityUtils.compute(6.0, context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount coupon:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsivityUtils.compute(18.0, context),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                    opacity: 0.8,
                    child: Text(
                      'Add coupon',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(18.0, context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: _buildAnimation,
    );
  }
}
