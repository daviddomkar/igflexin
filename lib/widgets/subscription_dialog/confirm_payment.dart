import 'package:flutter/material.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:igflexin/model/payment_error.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

import '../buttons.dart';

class ConfirmPayment extends StatefulWidget {
  ConfirmPayment({
    Key key,
    this.selectedPaymentMethod,
    this.routerController,
    this.onError,
    this.onDispose,
    this.willPop,
  }) : super(key: key);

  final RouterController routerController;
  final PaymentMethod selectedPaymentMethod;
  final Function(PaymentErrorException) onError;
  final Function onDispose;
  final Function(bool) willPop;

  @override
  _ConfirmPaymentState createState() {
    return _ConfirmPaymentState();
  }
}

class _ConfirmPaymentState extends State<ConfirmPayment>
    with SingleTickerProviderStateMixin {
  UserRepository _userRepository;
  SubscriptionRepository _subscriptionRepository;

  AnimationController _animationController;

  Animation<double> _cornerRadius;
  Animation<double> _contentOpacity;
  Animation<double> _width;
  Animation<double> _height;

  bool _processing = false;
  bool _eligibleForFreeTrial;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentOpacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: new Interval(0.000, 0.500, curve: Curves.ease),
      ),
    );

    _cornerRadius = Tween(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: new Interval(0.500, 1.000, curve: Curves.easeInExpo),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _userRepository = Provider.of<UserRepository>(context);

    if (!_processing) {
      _eligibleForFreeTrial = _userRepository.user.data.eligibleForFreeTrial;
    }

    _width = Tween(
            begin: ResponsivityUtils.compute(320.0, context),
            end: MediaQuery.of(context).size.width)
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: new Interval(0.500, 1.000, curve: Curves.easeInExpo),
      ),
    );

    _height = Tween(
            begin: ResponsivityUtils.compute(
                _eligibleForFreeTrial ? 225.0 : 205.0, context),
            end: MediaQuery.of(context).size.height)
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: new Interval(0.500, 1.000, curve: Curves.easeInExpo),
      ),
    );

    _userRepository.addListener(_onTrialEligibilityChanged);

    widget.routerController.registerAnimationController(_animationController);
    widget.routerController.addListener(_routerListener);
  }

  void _onTrialEligibilityChanged() {
    if (!_processing) {
      _eligibleForFreeTrial = _userRepository.user.data.eligibleForFreeTrial;
    }
  }

  void _routerListener() {
    if (widget.routerController.currentRoute.name !=
        'subscription_plan_payment_flow') {
      widget.onDispose();
    }
  }

  @override
  void dispose() {
    widget.routerController.removeListener(_routerListener);
    widget.routerController.unregisterAnimationController(_animationController);
    _userRepository.removeListener(_onTrialEligibilityChanged);
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      height: _height.value,
      padding: EdgeInsets.all(
        ResponsivityUtils.compute(20.0, context),
      ),
      width: _width.value,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsivityUtils.compute(_cornerRadius.value, context),
        ),
      ),
      child: Opacity(
        opacity: _contentOpacity.value,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirm payment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsivityUtils.compute(23.0, context),
                fontWeight: FontWeight.bold,
                color: _subscriptionRepository.planTheme.gradientStartColor,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: ResponsivityUtils.compute(20.0, context)),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(10.0, context),
              ),
              child: Text(
                'Buy ' +
                    '${getStringFromSubscriptionPlanInterval(_subscriptionRepository.selectedPlanInterval)[0].toUpperCase()}${getStringFromSubscriptionPlanInterval(_subscriptionRepository.selectedPlanInterval).substring(1)}' +
                    'ly ' +
                    getPrettyStringFromSubscriptionPlanType(
                        _subscriptionRepository.selectedPlanType) +
                    ' plan' +
                    ' with ' +
                    '${widget.selectedPaymentMethod.card.brand[0].toUpperCase()}${widget.selectedPaymentMethod.card.brand.substring(1)}' +
                    ' card **' +
                    widget.selectedPaymentMethod.card.last4 +
                    '.' +
                    (_eligibleForFreeTrial
                        ? ' You will be charged after first 7 days.'
                        : ''),
                textAlign: TextAlign.center,
              ),
            ),
            GradientButton(
              width: ResponsivityUtils.compute(
                  _processing ? 45.0 : 130.0, context),
              height: ResponsivityUtils.compute(45.0, context),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      opacity: !_processing ? 1.0 : 0.0,
                      child: Text(
                        'Ok',
                        style: TextStyle(
                          fontSize: ResponsivityUtils.compute(16.0, context),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      opacity: _processing ? 1.0 : 0.0,
                      child: Container(
                        width: ResponsivityUtils.compute(36.0, context),
                        height: ResponsivityUtils.compute(36.0, context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                if (_processing) return;

                setState(() {
                  _processing = true;
                });

                widget.willPop(false);

                try {
                  await _subscriptionRepository
                      .purchaseSelectedSubscriptionPlan(
                          widget.selectedPaymentMethod);
                  widget.willPop(true);
                } catch (e) {
                  widget.willPop(true);
                  if (e is PaymentErrorException) {
                    widget.onError(e);
                  } else {
                    widget.onError(null);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: _buildAnimation,
    );
  }
}
