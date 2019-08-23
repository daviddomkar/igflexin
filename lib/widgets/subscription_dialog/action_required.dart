import 'package:flutter/material.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

import '../buttons.dart';

class ActionRequired extends StatefulWidget {
  ActionRequired({
    Key key,
    this.paymentIntentSecret,
    this.routerController,
    this.onError,
    this.onDispose,
  }) : super(key: key);

  final RouterController routerController;
  final String paymentIntentSecret;
  final Function() onError;
  final Function onDispose;

  @override
  _ActionRequiredState createState() {
    return _ActionRequiredState();
  }
}

class _ActionRequiredState extends State<ActionRequired>
    with SingleTickerProviderStateMixin {
  SubscriptionRepository _subscriptionRepository;

  AnimationController _animationController;

  Animation<double> _cornerRadius;
  Animation<double> _contentOpacity;
  Animation<double> _width;
  Animation<double> _height;

  bool _processing = false;

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
            begin: ResponsivityUtils.compute(190.0, context),
            end: MediaQuery.of(context).size.height)
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: new Interval(0.500, 1.000, curve: Curves.easeInExpo),
      ),
    );

    widget.routerController.registerAnimationController(_animationController);
    widget.routerController.addListener(_routerListener);
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
              'Action required',
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
                'Action on your side is required to finish the payment.',
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

                try {
                  await _subscriptionRepository
                      .authenticatePayment(widget.paymentIntentSecret);
                } catch (e) {
                  widget.onError();
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
