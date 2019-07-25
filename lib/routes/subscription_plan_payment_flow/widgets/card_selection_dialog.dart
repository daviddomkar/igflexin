import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:igflexin/model/subscription_plan.dart';
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

  List<PaymentMethod> _paymentMethods;
  PaymentMethod _selectedPaymentMethod;

  AnimationController _animationController;

  Animation<double> _scale;

  AnimationController _zoomInController;

  Animation<double> _width;
  Animation<double> _height;
  Animation<Offset> _titleOffsetY;
  Animation<double> _titleOpacity;
  Animation<Offset> _contentOffsetY;
  Animation<double> _contentOpacity;

  AnimationController _addNewCardController;

  BorderRadius _borderRadius;

  bool _networkError = false;
  bool _addingCard = false;
  bool _processingPayment = false;

  bool _addingCardState = false;
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

    _zoomInController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _addNewCardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleOffsetY = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 10.0)).animate(
      CurvedAnimation(
        parent: _zoomInController,
        curve: new Interval(1.0 / 3.0, 2.0 / 3.0, curve: Curves.ease),
      ),
    );

    _titleOpacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _zoomInController,
        curve: new Interval(1.0 / 3.0, 2.0 / 3.0, curve: Curves.ease),
      ),
    );

    _contentOffsetY = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 10.0)).animate(
      CurvedAnimation(
        parent: _zoomInController,
        curve: new Interval(0.000, 1.0 / 3.0, curve: Curves.ease),
      ),
    );

    _contentOpacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _zoomInController,
        curve: new Interval(0.000, 1.0 / 3.0, curve: Curves.ease),
      ),
    );

    _borderRadius = BorderRadius.circular(30.0);

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _width = Tween(
            begin: ResponsivityUtils.compute(200.0, context),
            end: MediaQuery.of(context).size.width)
        .animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(2.0 / 3.0, 1.000, curve: Curves.easeInExpo),
    ));

    _height = Tween(
            begin: ResponsivityUtils.compute(200.0, context),
            end: MediaQuery.of(context).size.height)
        .animate(CurvedAnimation(
      parent: _zoomInController,
      curve: new Interval(2.0 / 3.0, 1.000, curve: Curves.easeInExpo),
    ));

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);

    fetchPaymentMethods();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

              await _zoomInController.reverse();
            }
          },
        );
      } else if (_selectedPaymentMethod != null) {
        return RoundedAlertDialog(
          title: Text(
            'Confirm payment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsivityUtils.compute(23.0, context),
              fontWeight: FontWeight.bold,
              color: Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
            ),
          ),
          content: Text(
            'Buy ' +
                getStringFromSubscriptionPlanInterval(_subscriptionRepository.selectedPlanInterval)
                    .toLowerCase() +
                'ly ' +
                getStringFromSubscriptionPlanType(_subscriptionRepository.selectedPlanType)
                    .toLowerCase()
                    .replaceAll(new RegExp(r'_'), ' ') +
                ' plan' +
                ' with ' +
                '${_selectedPaymentMethod.card.brand[0].toUpperCase()}${_selectedPaymentMethod.card.brand.substring(1)}' +
                ' card ending ' +
                _selectedPaymentMethod.card.last4,
            textAlign: TextAlign.center,
          ),
          actions: [
            GradientButton(
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
          ],
        );
      } else {
        return AnimatedBuilder(
          animation: _zoomInController,
          builder: (context, child) {
            // Just don't touch this as long as it works xd
            if (_zoomInController.lastElapsedDuration != null) {
              if (_zoomInController.lastElapsedDuration.inMilliseconds >= 1000 &&
                  _zoomInController.isAnimating &&
                  _zoomInController.status == AnimationStatus.forward) {
                if (!_addingCardState && _dialogState) {
                  print('dark');
                  Provider.of<SystemBarsRepository>(context).setDarkForeground();
                  _borderRadius = BorderRadius.zero;
                  _dialogState = false;
                  _addingCardState = true;
                }
              } else if (_zoomInController.lastElapsedDuration.inMilliseconds <= 1000 &&
                  _zoomInController.isAnimating &&
                  _zoomInController.status == AnimationStatus.reverse) {
                if (!_dialogState && _addingCardState) {
                  print('light');
                  Provider.of<SystemBarsRepository>(context).setLightForeground();
                  _borderRadius = BorderRadius.circular(30.0);
                  _addingCardState = false;
                  _dialogState = true;
                }
              }
            }

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
                            await _zoomInController.forward();

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
        if (_addingCard || _zoomInController.isAnimating) {
          await _addNewCardController.reverse();

          setState(() {
            _addingCard = false;
          });

          await _zoomInController.reverse();
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
