import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/repositories/system_bars_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';
import 'package:igflexin/resources/user.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/add_new_card.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/dialog.dart';
import 'package:igflexin/widgets/rounded_list_tile.dart';
import 'package:provider/provider.dart';

class CardSelectionDialog extends StatefulWidget {
  final RouterController routerController;

  @override
  _CardSelectionDialogState createState() {
    return _CardSelectionDialogState();
  }

  CardSelectionDialog({this.routerController});
}

class _CardSelectionDialogState extends State<CardSelectionDialog> with TickerProviderStateMixin {
  SubscriptionRepository _subscriptionRepository;
  UserRepository _userRepository;

  NavigatorState _navigator;

  List<PaymentMethod> _paymentMethods;
  PaymentMethod _selectedPaymentMethod;

  AnimationController _animationController;

  Animation<double> _scale;

  AnimationController _zoomInControllerTitleContent;

  Animation<double> _widthTitleContent;
  Animation<double> _heightTitleContent;
  Animation<Offset> _titleOffsetYTitleContent;
  Animation<double> _titleOpacityTitleContent;
  Animation<Offset> _contentOffsetYTitleContent;
  Animation<double> _contentOpacityTitleContent;

  AnimationController _zoomInControllerTitleContentButton;

  Animation<double> _widthTitleContentButton;
  Animation<double> _heightTitleContentButton;
  Animation<Offset> _titleOffsetYTitleContentButton;
  Animation<double> _titleOpacityTitleContentButton;
  Animation<Offset> _contentOffsetYTitleContentButton;
  Animation<double> _contentOpacityTitleContentButton;
  Animation<double> _buttonScaleTitleContentButton;

  AnimationController _addNewCardController;

  BorderRadius _borderRadius;

  bool _networkError = false;
  bool _addingCard = false;
  bool _processingPayment = false;
  bool _disposeNow = false;

  bool _fullscreenState = false;
  bool _dialogState = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: new Interval(0.000, 1.000, curve: Curves.elasticOut),
      ),
    );

    _zoomInControllerTitleContent = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _addNewCardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleOffsetYTitleContent = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 10.0)).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContent,
        curve: new Interval(1.0 / 3.0, 2.0 / 3.0, curve: Curves.ease),
      ),
    );

    _titleOpacityTitleContent = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContent,
        curve: new Interval(1.0 / 3.0, 2.0 / 3.0, curve: Curves.ease),
      ),
    );

    _contentOffsetYTitleContent = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 10.0)).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContent,
        curve: new Interval(0.000, 1.0 / 3.0, curve: Curves.ease),
      ),
    );

    _contentOpacityTitleContent = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContent,
        curve: new Interval(0.000, 1.0 / 3.0, curve: Curves.ease),
      ),
    );

    _zoomInControllerTitleContentButton = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _titleOffsetYTitleContentButton =
        Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 10.0)).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContentButton,
        curve: new Interval(0.500, 0.750, curve: Curves.ease),
      ),
    );

    _titleOpacityTitleContentButton = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContentButton,
        curve: new Interval(0.500, 0.750, curve: Curves.ease),
      ),
    );

    _contentOffsetYTitleContentButton =
        Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 10.0)).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContentButton,
        curve: new Interval(0.250, 0.500, curve: Curves.ease),
      ),
    );

    _contentOpacityTitleContentButton = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContentButton,
        curve: new Interval(0.250, 0.500, curve: Curves.ease),
      ),
    );

    _buttonScaleTitleContentButton = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _zoomInControllerTitleContentButton,
        curve: new Interval(0.000, 0.500, curve: Curves.elasticIn),
      ),
    );

    _borderRadius = BorderRadius.circular(30.0);

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _navigator = Navigator.of(context);

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _userRepository = Provider.of<UserRepository>(context);

    _widthTitleContent = Tween(
            begin: ResponsivityUtils.compute(200.0, context),
            end: MediaQuery.of(context).size.width)
        .animate(CurvedAnimation(
      parent: _zoomInControllerTitleContent,
      curve: new Interval(2.0 / 3.0, 1.000, curve: Curves.easeInExpo),
    ));

    _heightTitleContent = Tween(
            begin: ResponsivityUtils.compute(200.0, context),
            end: MediaQuery.of(context).size.height)
        .animate(CurvedAnimation(
      parent: _zoomInControllerTitleContent,
      curve: new Interval(2.0 / 3.0, 1.000, curve: Curves.easeInExpo),
    ));

    _widthTitleContentButton = Tween(
            begin: ResponsivityUtils.compute(200.0, context),
            end: MediaQuery.of(context).size.width)
        .animate(CurvedAnimation(
      parent: _zoomInControllerTitleContentButton,
      curve: new Interval(0.750, 1.000, curve: Curves.easeInExpo),
    ));

    _heightTitleContentButton = Tween(
            begin: ResponsivityUtils.compute(
                _userRepository.user.state == UserState.Authenticated &&
                        _userRepository.user.data.eligibleForFreeTrial
                    ? 120.0
                    : 100,
                context),
            end: MediaQuery.of(context).size.height)
        .animate(CurvedAnimation(
      parent: _zoomInControllerTitleContentButton,
      curve: new Interval(0.750, 1.000, curve: Curves.easeInExpo),
    ));

    widget.routerController.registerAnimationController(_zoomInControllerTitleContent);
    widget.routerController.registerAnimationController(_zoomInControllerTitleContentButton);

    widget.routerController.addListener(_routerListener);

    fetchPaymentMethods();
  }

  void _routerListener() {
    if (widget.routerController.currentRoute.name != 'subscription_plan_payment_flow') {
      if (!_disposeNow) {
        _disposeNow = true;
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _addNewCardController.dispose();
    _zoomInControllerTitleContent.dispose();
    _zoomInControllerTitleContentButton.dispose();

    // widget.routerController.removeListener(_routerListener);

    widget.routerController.unregisterAnimationController(_zoomInControllerTitleContent);
    widget.routerController.unregisterAnimationController(_zoomInControllerTitleContentButton);
    super.dispose();
  }

  void fetchPaymentMethods() {
    if (_paymentMethods == null) {
      if (mounted)
        _animationController.reverse().whenComplete(() {
          if (mounted) {
            setState(() {
              _networkError = false;
            });
            _animationController.forward();
          }
        });
      _subscriptionRepository.getPaymentMethods().then((paymentMethods) {
        if (mounted)
          _animationController.reverse().whenComplete(() {
            if (mounted) {
              setState(() {
                _paymentMethods = paymentMethods;
              });
              _animationController.forward();
            }
          });
      }).catchError((error) {
        if (mounted)
          _animationController.reverse().whenComplete(() {
            if (mounted) {
              setState(() {
                _networkError = true;
              });
              _animationController.forward();
            }
          });
      });
    }
  }

  Widget _buildChild() {
    if (_paymentMethods != null) {
      if (_addingCard) {
        return AddNewCard(
          controller: _addNewCardController,
          refreshPaymentMethodsFunction: () async {
            final paymentMethods = await _subscriptionRepository.getPaymentMethods();

            if (mounted) {
              setState(() {
                _paymentMethods = paymentMethods;
              });

              await _addNewCardController.reverse();

              if (mounted) {
                setState(() {
                  _addingCard = false;
                });
              }

              await _zoomInControllerTitleContent.reverse();
            }
          },
        );
      } else if (_selectedPaymentMethod != null) {
        return AnimatedBuilder(
          animation: _zoomInControllerTitleContentButton,
          builder: (context, child) {
            if (_zoomInControllerTitleContentButton.lastElapsedDuration != null) {
              if (_zoomInControllerTitleContentButton.lastElapsedDuration.inMilliseconds >= 1500 &&
                  _zoomInControllerTitleContentButton.isAnimating &&
                  _zoomInControllerTitleContentButton.status == AnimationStatus.forward) {
                if (!_fullscreenState && _dialogState) {
                  Provider.of<SystemBarsRepository>(context).setDarkForeground();
                  _borderRadius = BorderRadius.zero;
                  _dialogState = false;
                  _fullscreenState = true;
                }
              } else if (_zoomInControllerTitleContentButton.lastElapsedDuration.inMilliseconds <=
                      1500 &&
                  _zoomInControllerTitleContentButton.isAnimating &&
                  _zoomInControllerTitleContentButton.status == AnimationStatus.reverse) {
                if (!_dialogState && _fullscreenState) {
                  Provider.of<SystemBarsRepository>(context).setLightForeground();
                  _borderRadius = BorderRadius.circular(30.0);
                  _fullscreenState = false;
                  _dialogState = true;
                }
              }
            }

            return RoundedAlertDialog(
              padding: EdgeInsets.zero,
              width: _widthTitleContentButton.value,
              height: _heightTitleContentButton.value,
              borderRadius: _borderRadius,
              title: Transform.translate(
                offset: _titleOffsetYTitleContentButton.value,
                child: Opacity(
                  opacity: _titleOpacityTitleContentButton.value,
                  child: Text(
                    'Confirm payment',
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
                offset: _contentOffsetYTitleContentButton.value,
                child: Opacity(
                  opacity: _contentOpacityTitleContentButton.value,
                  child: Text(
                    'Buy ' +
                        getStringFromSubscriptionPlanInterval(
                                _subscriptionRepository.selectedPlanInterval)
                            .toLowerCase() +
                        'ly ' +
                        getStringFromSubscriptionPlanType(_subscriptionRepository.selectedPlanType)
                            .toLowerCase()
                            .replaceAll(new RegExp(r'_'), ' ') +
                        ' plan' +
                        ' with ' +
                        '${_selectedPaymentMethod.card.brand[0].toUpperCase()}${_selectedPaymentMethod.card.brand.substring(1)}' +
                        ' card ending ' +
                        _selectedPaymentMethod.card.last4 +
                        '.' +
                        (_userRepository.user.data.eligibleForFreeTrial
                            ? ' You will be charged after first 7 days.'
                            : ''),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              actions: [
                Transform.scale(
                  scale: _buttonScaleTitleContentButton.value,
                  child: GradientButton(
                    width: ResponsivityUtils.compute(_processingPayment ? 40.0 : 100.0, context),
                    height: ResponsivityUtils.compute(40.0, context),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.ease,
                            opacity: !_processingPayment ? 1.0 : 0.0,
                            child: Text(
                              'CONFIRM',
                              style: TextStyle(
                                fontSize: ResponsivityUtils.compute(15.0, context),
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
                            opacity: _processingPayment ? 1.0 : 0.0,
                            child: Container(
                              width: 28.0,
                              height: 28.0,
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
                      setState(() {
                        _processingPayment = true;
                      });

                      try {
                        await _subscriptionRepository
                            .purchaseSelectedSubscriptionPlan(_selectedPaymentMethod);
                      } catch (e) {
                        setState(() {
                          _processingPayment = false;
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      } else {
        return AnimatedBuilder(
          animation: _zoomInControllerTitleContent,
          builder: (context, child) {
            if (_zoomInControllerTitleContent.lastElapsedDuration != null) {
              if (_zoomInControllerTitleContent.lastElapsedDuration.inMilliseconds >= 1000 &&
                  _zoomInControllerTitleContent.isAnimating &&
                  _zoomInControllerTitleContent.status == AnimationStatus.forward) {
                if (!_fullscreenState && _dialogState) {
                  Provider.of<SystemBarsRepository>(context).setDarkForeground();
                  _borderRadius = BorderRadius.zero;
                  _dialogState = false;
                  _fullscreenState = true;
                }
              } else if (_zoomInControllerTitleContent.lastElapsedDuration.inMilliseconds <= 1000 &&
                  _zoomInControllerTitleContent.isAnimating &&
                  _zoomInControllerTitleContent.status == AnimationStatus.reverse) {
                if (!_dialogState && _fullscreenState) {
                  Provider.of<SystemBarsRepository>(context).setLightForeground();
                  _borderRadius = BorderRadius.circular(30.0);
                  _fullscreenState = false;
                  _dialogState = true;
                }
              }
            }

            return RoundedAlertDialog(
              padding: EdgeInsets.zero,
              width: _widthTitleContent.value,
              height: _heightTitleContent.value,
              borderRadius: _borderRadius,
              title: Transform.translate(
                offset: _titleOffsetYTitleContent.value,
                child: Opacity(
                  opacity: _titleOpacityTitleContent.value,
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
                offset: _contentOffsetYTitleContent.value,
                child: Opacity(
                  opacity: _contentOpacityTitleContent.value,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
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
                            await _zoomInControllerTitleContent.forward();

                            setState(() {
                              _addingCard = true;
                            });

                            await _addNewCardController.forward();
                          },
                        );
                      } else {
                        return RoundedListTile(
                          leading: Icon(
                            Icons.credit_card,
                          ),
                          title: Text(
                            '${_paymentMethods[index].card.brand[0].toUpperCase()}${_paymentMethods[index].card.brand.substring(1)}' +
                                ' card ending ' +
                                _paymentMethods[index].card.last4,
                          ),
                          onTap: () {
                            _animationController.reverse().whenComplete(() {
                              if (mounted) {
                                setState(() {
                                  _selectedPaymentMethod = _paymentMethods[index];
                                });
                                _animationController.forward();
                              }
                            });
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
              actions: [],
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
        if (_disposeNow) {
          return true;
        } else if (_addingCard || _zoomInControllerTitleContent.isAnimating) {
          await _addNewCardController.reverse();

          setState(() {
            _addingCard = false;
          });

          await _zoomInControllerTitleContent.reverse();
          return false;
        } else if (_selectedPaymentMethod != null) {
          if (_processingPayment) {
            return false;
          }

          await _animationController.reverse();

          setState(() {
            _selectedPaymentMethod = null;
          });

          await _animationController.forward();
          return false;
        } else {
          await _animationController.reverse();
          return true;
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: _buildAnimation,
      ),
    );
  }
}
