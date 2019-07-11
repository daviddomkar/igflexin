import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/repositories/system_bars_repository.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/add_new_card.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/dialog.dart';
import 'package:igflexin/widgets/rounded_list_tile.dart';
import 'package:provider/provider.dart';

class CardSelectionDialog extends StatefulWidget {
  @override
  _CardSelectionDialogState createState() {
    return _CardSelectionDialogState();
  }
}

class _CardSelectionDialogState extends State<CardSelectionDialog> with TickerProviderStateMixin {
  SubscriptionRepository _subscriptionRepository;

  AnimationController _controller;

  Animation<double> _scale;

  AnimationController _zoomInController;

  Animation<double> _width;
  Animation<double> _height;
  Animation<Offset> _titleOffsetY;
  Animation<double> _titleOpacity;
  Animation<Offset> _contentOffsetY;
  Animation<double> _contentOpacity;
  Animation<double> _buttonScale;

  BorderRadius _borderRadius;

  List<PaymentMethod> _paymentMethods;
  bool _networkError = false;
  bool _addingCard = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.000, 1.000, curve: Curves.elasticOut),
    ));

    _zoomInController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _titleOffsetY = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 10.0)).animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(0.250, 0.500, curve: Curves.ease),
    ));

    _titleOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(0.250, 0.500, curve: Curves.ease),
    ));

    _contentOffsetY =
        Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 10.0)).animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(0.000, 0.250, curve: Curves.ease),
    ));

    _contentOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(0.000, 0.250, curve: Curves.ease),
    ));

    _buttonScale = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(0.000, 0.500, curve: Curves.elasticIn),
    ));

    _borderRadius = BorderRadius.circular(30.0);

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _width = Tween(
            begin: ResponsivityUtils.compute(200.0, context),
            end: MediaQuery.of(context).size.width)
        .animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(0.500, 0.750, curve: Curves.easeInExpo),
    ));

    _height = Tween(
            begin: ResponsivityUtils.compute(120.0, context),
            end: MediaQuery.of(context).size.height)
        .animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(0.500, 0.750, curve: Curves.easeInExpo),
    ));

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);

    fetchPaymentMethods();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fetchPaymentMethods() {
    if (_paymentMethods == null) {
      if (mounted)
        _controller.reverse().whenComplete(() {
          if (mounted) {
            setState(() {
              _networkError = false;
            });
            _controller.forward();
          }
        });
      _subscriptionRepository.getPaymentMethods().then((paymentMethods) {
        if (mounted)
          _controller.reverse().whenComplete(() {
            if (mounted) {
              setState(() {
                _paymentMethods = paymentMethods;
              });
              _controller.forward();
            }
          });
      }).catchError((error) {
        if (mounted)
          _controller.reverse().whenComplete(() {
            if (mounted) {
              setState(() {
                _networkError = true;
              });
              _controller.forward();
            }
          });
      });
    }
  }

  Widget _buildChild() {
    if (_paymentMethods != null) {
      if (_addingCard) {
        return AddNewCard();
      } else {
        return AnimatedBuilder(
          animation: _zoomInController,
          builder: (context, child) {
            return RoundedAlertDialog(
              padding: EdgeInsets.zero,
              width: _width.value,
              height: _height.value,
              borderRadius: _borderRadius,
              title: Transform.translate(
                offset: _titleOffsetY.value,
                child: Opacity(
                  opacity: _titleOpacity.value,
                  child: Text(
                    'Select your card',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsivityUtils.compute(23.0, context),
                      fontWeight: FontWeight.bold,
                      color:
                          Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
                    ),
                  ),
                ),
              ),
              content: Transform.translate(
                offset: _contentOffsetY.value,
                child: Opacity(
                  opacity: _contentOpacity.value,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _paymentMethods.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _paymentMethods.length) {
                        return RoundedListTile(
                          leading: Icon(
                            Icons.add,
                            color: Provider.of<SubscriptionRepository>(context)
                                .planTheme
                                .gradientEndColor,
                          ),
                          title: Text(
                            'Add new card',
                            style: TextStyle(
                              color: Provider.of<SubscriptionRepository>(context)
                                  .planTheme
                                  .gradientEndColor,
                            ),
                          ),
                          onTap: () async {
                            var borderRadiusFuture =
                                Future.delayed(const Duration(milliseconds: 1250), () {
                              if (_zoomInController.status == AnimationStatus.forward) {
                                _borderRadius = BorderRadius.zero;
                                Provider.of<SystemBarsRepository>(context).setDarkForeground();
                              }
                            });

                            List<Future> futures = [
                              borderRadiusFuture,
                              _zoomInController.forward(),
                            ];

                            await Future.wait(futures);

                            setState(() {
                              _addingCard = true;
                            });
                          },
                        );
                      } else {
                        return RoundedListTile(
                          leading: Icon(
                            Icons.credit_card,
                          ),
                          title: Text(
                            'ID: ' + _paymentMethods[index].id,
                          ),
                          onTap: () {},
                        );
                      }
                    },
                  ),
                ),
              ),
              actions: [
                Transform.scale(
                  scale: _buttonScale.value,
                  child: GradientButton(
                    width: ResponsivityUtils.compute(120.0, context),
                    height: ResponsivityUtils.compute(40.0, context),
                    child: Text(
                      'BUY PLAN',
                      style: TextStyle(
                          fontSize: ResponsivityUtils.compute(15.0, context), color: Colors.white),
                    ),
                    onPressed: () {
                      fetchPaymentMethods();
                    },
                  ),
                ),
              ],
            );
          },
        );
      }
    } else if (_networkError) {
      return RoundedAlertDialog(
        title: Text(
          'Network error',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsivityUtils.compute(23.0, context),
            fontWeight: FontWeight.bold,
            color: Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
          ),
        ),
        content: Text(
          'Check your internet connection!',
          textAlign: TextAlign.center,
        ),
        actions: [
          GradientButton(
            width: ResponsivityUtils.compute(80.0, context),
            height: ResponsivityUtils.compute(40.0, context),
            child: Text(
              'RETRY',
              style: TextStyle(
                  fontSize: ResponsivityUtils.compute(15.0, context), color: Colors.white),
            ),
            onPressed: () {
              fetchPaymentMethods();
            },
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            _subscriptionRepository.planTheme.gradientEndColor,
          ),
        ),
      );
    }
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Transform.scale(
      scale: _scale.value,
      child: _buildChild(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_addingCard || _zoomInController.isAnimating) {
          setState(() {
            _addingCard = false;
          });

          var borderRadiusFuture = Future.delayed(
              Duration(
                  milliseconds: _zoomInController.lastElapsedDuration != null
                      ? (500 - (2000 - _zoomInController.lastElapsedDuration.inMilliseconds) > 0
                          ? 500 - (2000 - _zoomInController.lastElapsedDuration.inMilliseconds)
                          : 0)
                      : 500), () {
            if (_zoomInController.status == AnimationStatus.reverse) {
              _borderRadius = BorderRadius.circular(30.0);
              Provider.of<SystemBarsRepository>(context).setLightForeground();
            }
          });

          List<Future> futures = [borderRadiusFuture, _zoomInController.reverse()];

          await Future.wait(futures);

          return false;
        } else {
          await _controller.reverse();
          return true;
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: _buildAnimation,
      ),
    );
  }
}
