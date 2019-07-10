import 'package:flutter/material.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

class Title extends StatelessWidget {
  Title({Key key, @required this.interval, @required this.type, @required this.controller})
      : opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOut),
        )),
        offsetY = Tween(begin: 15.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOut),
        )),
        super(key: key);

  final SubscriptionPlanInterval interval;
  final SubscriptionPlanType type;

  final AnimationController controller;

  final Animation<double> opacity;
  final Animation<double> offsetY;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Transform.translate(
      offset: Offset(0.0, offsetY.value),
      child: Opacity(
        opacity: opacity.value,
        child: Text(
          getStringFromSubscriptionPlanInterval(interval).toUpperCase() +
              'LY ' +
              getStringFromSubscriptionPlanType(type)
                  .toUpperCase()
                  .replaceAll(new RegExp(r'_'), ' ') +
              ' PLAN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: ResponsivityUtils.compute(23.0, context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: _buildAnimation,
    );
  }
}
