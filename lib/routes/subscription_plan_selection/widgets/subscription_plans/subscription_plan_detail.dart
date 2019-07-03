import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:igflexin/core/server.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/models/subscription_plan.dart';
import 'package:igflexin/models/subscription_plan_theme.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class SubscriptionPlanDetail extends StatelessWidget {
  SubscriptionPlanDetail({Key key, this.active, this.planType, this.controller})
      : sideMargin = Tween(begin: 0.0, end: 10.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.5 / 2.25, curve: Curves.easeOutExpo),
        )),
        borderRadius = Tween(begin: 0.0, end: 30.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.5 / 2.25, curve: Curves.easeOutExpo),
        )),
        contentOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.5 / 2.25 * 2, 0.5 / 2.25 * 3, curve: Curves.ease),
        )),
        contentOffsetY = Tween(begin: 10.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.5 / 2.25 * 2, 0.5 / 2.25 * 3, curve: Curves.ease),
        )),
        plan = SubscriptionPlan(planType),
        planTheme = SubscriptionPlanTheme(planType),
        super(key: key);

  final bool active;
  final SubscriptionPlanType planType;

  final AnimationController controller;

  final Animation<double> sideMargin;
  final Animation<double> borderRadius;
  final Animation<double> contentOpacity;
  final Animation<double> contentOffsetY;

  final SubscriptionPlan plan;
  final SubscriptionPlanTheme planTheme;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(
        top: active ? 0 : ResponsivityUtils.compute(40, context),
        right: active ? ResponsivityUtils.compute(sideMargin.value, context) : 0,
        left: active ? ResponsivityUtils.compute(sideMargin.value, context) : 0,
        bottom: active ? 0 : ResponsivityUtils.compute(40, context),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            ResponsivityUtils.compute(active ? borderRadius.value : 30.0, context)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          colors: [planTheme.gradientStartColor, planTheme.gradientEndColor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuint,
            margin: EdgeInsets.only(
                top: ResponsivityUtils.compute(active ? 20.0 : 10.0, context),
                bottom: ResponsivityUtils.compute(active ? 15.0 : 5.0, context)),
            child: Transform.translate(
              offset: Offset(0.0, contentOffsetY.value),
              child: Opacity(
                opacity: contentOpacity.value,
                child: Text(
                  plan.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsivityUtils.compute(30.0, context),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0.0, contentOffsetY.value),
            child: Opacity(
              opacity: contentOpacity.value,
              child: Column(
                children: [
                  for (var feature in plan.features)
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: ResponsivityUtils.compute(15.0, context)),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutQuint,
                            padding: EdgeInsets.symmetric(
                                vertical: ResponsivityUtils.compute(active ? 10.0 : 5.0, context),
                                horizontal: ResponsivityUtils.compute(10.0, context)),
                            child: Text(
                              feature,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuint,
            margin: EdgeInsets.only(
              top: ResponsivityUtils.compute(active ? 10.0 : 5.0, context),
              bottom: ResponsivityUtils.compute(active ? 20.0 : 5.0, context),
              left: ResponsivityUtils.compute(20.0, context),
              right: ResponsivityUtils.compute(20.0, context),
            ),
            child: Transform.translate(
              offset: Offset(0.0, contentOffsetY.value),
              child: Opacity(
                opacity: contentOpacity.value,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.monthlyPrice,
                          style: TextStyle(
                            fontSize: ResponsivityUtils.compute(20.0, context),
                            color: Colors.white,
                          ),
                        ),
                        CurvedWhiteButton(
                          child: Text(
                            'SELECT',
                            style: TextStyle(color: planTheme.gradientStartColor),
                          ),
                          onPressed: () {
                            Provider.of<SubscriptionRepository>(context)
                                .setSelectedPlanInterval(SubscriptionPlanInterval.Month);

                            Router.of<MainRouterController>(context)
                                .push('subscription_plan_payment_flow');
                          },
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.white,
                      height: 2.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.yearlyPrice,
                          style: TextStyle(
                            fontSize: ResponsivityUtils.compute(20.0, context),
                            color: Colors.white,
                          ),
                        ),
                        CurvedWhiteButton(
                          child: Text(
                            'SELECT',
                            style: TextStyle(color: planTheme.gradientStartColor),
                          ),
                          onPressed: () {
                            Provider.of<SubscriptionRepository>(context)
                                .setSelectedPlanInterval(SubscriptionPlanInterval.Year);

                            Router.of<MainRouterController>(context)
                                .push('subscription_plan_payment_flow');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
