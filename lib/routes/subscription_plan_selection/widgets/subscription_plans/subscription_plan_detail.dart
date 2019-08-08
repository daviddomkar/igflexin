import 'package:flutter/material.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/model/subscription_plan_theme.dart';
import 'package:igflexin/repositories/user_repository.dart';
import 'package:igflexin/resources/user.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class SubscriptionPlanDetail extends StatefulWidget {
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
          curve:
              new Interval(0.5 / 2.25 * 2, 0.5 / 2.25 * 3, curve: Curves.ease),
        )),
        contentOffsetY = Tween(begin: 10.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve:
              new Interval(0.5 / 2.25 * 2, 0.5 / 2.25 * 3, curve: Curves.ease),
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

  @override
  _SubscriptionPlanDetailState createState() => _SubscriptionPlanDetailState();
}

class _SubscriptionPlanDetailState extends State<SubscriptionPlanDetail> {
  UserRepository _userRepository;
  bool _eligibleForFreeTrial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _userRepository = Provider.of<UserRepository>(context);

    if (_userRepository.user.state == UserState.Authenticated) {
      _eligibleForFreeTrial = _userRepository.user.data.eligibleForFreeTrial;
    }
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(
        top: widget.active ? 0 : ResponsivityUtils.compute(40, context),
        right: widget.active
            ? ResponsivityUtils.compute(widget.sideMargin.value, context)
            : 0,
        left: widget.active
            ? ResponsivityUtils.compute(widget.sideMargin.value, context)
            : 0,
        bottom: widget.active ? 0 : ResponsivityUtils.compute(40, context),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsivityUtils.compute(
            widget.active ? widget.borderRadius.value : 30.0, context)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          colors: [
            widget.planTheme.gradientStartColor,
            widget.planTheme.gradientEndColor
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuint,
            margin: EdgeInsets.only(
                top: ResponsivityUtils.compute(
                    widget.active ? 20.0 : 10.0, context),
                bottom: ResponsivityUtils.compute(
                    widget.active ? 15.0 : 5.0, context)),
            child: Transform.translate(
              offset: Offset(0.0, widget.contentOffsetY.value),
              child: Opacity(
                opacity: widget.contentOpacity.value,
                child: Text(
                  widget.plan.name,
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
            offset: Offset(0.0, widget.contentOffsetY.value),
            child: Opacity(
              opacity: widget.contentOpacity.value,
              child: Column(
                children: [
                  for (var i = _eligibleForFreeTrial ? 0 : 1;
                      i < widget.plan.features.length;
                      i++)
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: ResponsivityUtils.compute(15.0, context),
                          ),
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
                              vertical: ResponsivityUtils.compute(
                                  widget.active ? 10.0 : 3.0, context),
                              horizontal:
                                  ResponsivityUtils.compute(10.0, context),
                            ),
                            child: Text(
                              widget.plan.features[i],
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
              top:
                  ResponsivityUtils.compute(widget.active ? 8.0 : 3.0, context),
              bottom:
                  ResponsivityUtils.compute(widget.active ? 8.0 : 3.0, context),
              left: ResponsivityUtils.compute(20.0, context),
              right: ResponsivityUtils.compute(20.0, context),
            ),
            child: Transform.translate(
              offset: Offset(0.0, widget.contentOffsetY.value),
              child: Opacity(
                opacity: widget.contentOpacity.value,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.plan.monthlyPrice,
                          style: TextStyle(
                            fontSize: ResponsivityUtils.compute(20.0, context),
                            color: Colors.white,
                          ),
                        ),
                        CurvedWhiteButton(
                          child: Text(
                            _eligibleForFreeTrial ? 'TRY FREE' : 'SELECT',
                            style: TextStyle(
                                color: widget.planTheme.gradientStartColor),
                          ),
                          onPressed: () {
                            Provider.of<SubscriptionRepository>(context)
                                .setSelectedPlanInterval(
                                    SubscriptionPlanInterval.Month);

                            /*Router.of<MainRouterController>(context)
                                .push('subscription_plan_payment_flow');*/
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
                          widget.plan.yearlyPrice,
                          style: TextStyle(
                            fontSize: ResponsivityUtils.compute(20.0, context),
                            color: Colors.white,
                          ),
                        ),
                        CurvedWhiteButton(
                          child: Text(
                            _eligibleForFreeTrial ? 'TRY FREE' : 'SELECT',
                            style: TextStyle(
                                color: widget.planTheme.gradientStartColor),
                          ),
                          onPressed: () {
                            Provider.of<SubscriptionRepository>(context)
                                .setSelectedPlanInterval(
                                    SubscriptionPlanInterval.Year);

                            /*Router.of<MainRouterController>(context)
                                .push('subscription_plan_payment_flow');*/
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
      animation: widget.controller,
      builder: _buildAnimation,
    );
  }
}
