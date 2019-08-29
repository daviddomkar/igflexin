import 'package:flutter/material.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/model/payment_error.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/keyboard_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/subscription_dialog/action_required.dart';
import 'package:igflexin/widgets/subscription_dialog/attach_payment_method.dart';
import 'package:igflexin/widgets/subscription_dialog/confirm_payment.dart';
import 'package:igflexin/widgets/subscription_dialog/pay_invoice.dart';
import 'package:igflexin/widgets/subscription_dialog/payment_methods.dart';
import 'package:provider/provider.dart';

import '../../router_controller.dart';

class WillPopNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

enum SubscriptionActionType {
  Purchase,
  UpgradeOrDowngrade,
  ChangeBillingCycle,
  RequiresPaymentMethod,
  RequiresAction,
  ManagePaymentMethods,
  Cancel,
  Renew,
}

class SubscriptionDialog extends StatefulWidget {
  SubscriptionDialog({Key key, this.actionType, this.routerController})
      : super(key: key);

  final RouterController routerController;
  final SubscriptionActionType actionType;

  @override
  _SubscriptionDialogState createState() {
    return _SubscriptionDialogState();
  }
}

class _SubscriptionDialogState extends State<SubscriptionDialog>
    with SingleTickerProviderStateMixin {
  SubscriptionRepository _subscriptionRepository;

  AnimationController _animationController;

  Animation<Color> _fadeInAnimation;
  Animation<double> _scaleContentInAnimation;

  PaymentMethod _selectedPaymentMethod;

  bool _willPop = true;
  bool _disposeNow = false;

  String _paymentIntentSecret;
  String _error;
  WillPopNotifier _willPopNotifier = new WillPopNotifier();

  bool _requiresPayment = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation =
        ColorTween(begin: Colors.transparent, end: Colors.black54)
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.000, 0.250, curve: Curves.easeOutExpo),
    ));

    _scaleContentInAnimation =
        Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.000, 1.000, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildChild(BuildContext context) {
    if (_error != null) {
      return Container(
        padding: EdgeInsets.all(
          ResponsivityUtils.compute(20.0, context),
        ),
        width: ResponsivityUtils.compute(320.0, context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsivityUtils.compute(20.0, context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Error',
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
                _error,
                textAlign: TextAlign.center,
              ),
            ),
            GradientButton(
              width: ResponsivityUtils.compute(130.0, context),
              height: ResponsivityUtils.compute(45.0, context),
              child: Text(
                'Ok',
                style: TextStyle(
                  fontSize: ResponsivityUtils.compute(16.0, context),
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
            ),
          ],
        ),
      );
    } else {
      switch (widget.actionType) {
        case SubscriptionActionType.Purchase:
          if (_paymentIntentSecret != null) {
            return ActionRequired(
              paymentIntentSecret: _paymentIntentSecret,
              routerController: widget.routerController,
              onError: () {
                setState(() {
                  _error = 'Could not complete action. Please try again later.';
                  _selectedPaymentMethod = null;
                  _paymentIntentSecret = null;
                });
              },
              onDispose: () {
                if (!_disposeNow) {
                  _disposeNow = true;
                  Navigator.pop(context);
                }
              },
            );
          } else if (_selectedPaymentMethod != null) {
            return ConfirmPayment(
              selectedPaymentMethod: _selectedPaymentMethod,
              routerController: widget.routerController,
              onError: (maybeException) {
                if (maybeException != null) {
                  switch (maybeException.errorType) {
                    case PaymentErrorType.RequiresPaymentMethod:
                      setState(() {
                        _error =
                            'Cannot purchase subscription using this payment method. Select another one.';
                        _selectedPaymentMethod = null;
                      });
                      break;
                    case PaymentErrorType.RequiresAction:
                      setState(() {
                        _paymentIntentSecret =
                            maybeException.paymentIntentSecret;
                      });
                      break;
                  }
                } else {
                  setState(() {
                    _error =
                        'Error purchasing subscription. Please try again later.';
                    _selectedPaymentMethod = null;
                  });
                }
              },
              onDispose: () {
                if (!_disposeNow) {
                  _disposeNow = true;
                  Navigator.pop(context);
                }
              },
            );
          } else {
            return PaymentMethods(
              title: 'Select card',
              willPopNotifier: _willPopNotifier,
              onPaymentMethodSelected: (paymentMethod) {
                setState(() {
                  _selectedPaymentMethod = paymentMethod;
                });
              },
              willPop: (willPop) {
                _willPop = willPop;
              },
            );
          }
          break;
        case SubscriptionActionType.UpgradeOrDowngrade:
          // TODO: Handle this case.
          break;
        case SubscriptionActionType.ChangeBillingCycle:
          // TODO: Handle this case.
          break;
        case SubscriptionActionType.RequiresPaymentMethod:
          if (_selectedPaymentMethod != null) {
            if (_requiresPayment) {
              return PayInvoice(
                paymentMethod: _selectedPaymentMethod,
                onSuccess: () {
                  setState(() {
                    _requiresPayment = false;
                    _selectedPaymentMethod = null;
                  });
                  Navigator.maybePop(context);
                },
                onError: () {
                  setState(() {
                    _error =
                        'Error occured while paying for subscription with new payment method. Please try again later.';
                    _selectedPaymentMethod = null;
                    _requiresPayment = false;
                  });
                },
              );
            } else {
              return AttachPaymentMethod(
                paymentMethod: _selectedPaymentMethod,
                onSuccess: (requiresPayment) {
                  if (requiresPayment) {
                    setState(() {
                      _requiresPayment = true;
                    });
                  } else {
                    setState(() {
                      _selectedPaymentMethod = null;
                    });
                    Navigator.maybePop(context);
                  }
                },
                onError: () {
                  setState(() {
                    _error =
                        'Error occured while attaching payment method. Please try again later.';
                    _selectedPaymentMethod = null;
                  });
                },
              );
            }
          } else {
            return PaymentMethods(
              title: 'Select card',
              willPopNotifier: _willPopNotifier,
              onPaymentMethodSelected: (paymentMethod) {
                setState(() {
                  _selectedPaymentMethod = paymentMethod;
                });
              },
              willPop: (willPop) {
                _willPop = willPop;
              },
            );
          }
          break;
        case SubscriptionActionType.RequiresAction:
          return ActionRequired(
            paymentIntentSecret:
                _subscriptionRepository.subscription.data.paymentIntentSecret,
            routerController: widget.routerController,
            onSuccess: () {
              Navigator.maybePop(context);
            },
            onError: () {
              setState(() {
                _error = 'Could not complete action. Please try again later.';
              });
            },
          );
          break;
        case SubscriptionActionType.ManagePaymentMethods:
          return PaymentMethods(
            willPopNotifier: _willPopNotifier,
            willPop: (willPop) {
              _willPop = willPop;
            },
          );
          break;
        case SubscriptionActionType.Cancel:
          // TODO: Handle this case.
          break;
        case SubscriptionActionType.Renew:
          // TODO: Handle this case.
          break;
      }
    }
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Material(
      color: _fadeInAnimation.value,
      child: SystemBarsInfoProvider(
        builder: (context, child, systemBarsInfo, orientation) {
          return KeyboardInfoProvider(
            builder: (context, keyboardInfo) {
              final bottomMargin = orientation == Orientation.landscape ||
                      (orientation == Orientation.portrait &&
                          keyboardInfo.offsetY >
                              systemBarsInfo.navigationBarHeight)
                  ? keyboardInfo.offsetY
                  : 0.0;

              return Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  bottom: bottomMargin,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: IntrinsicHeight(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight:
                              MediaQuery.of(context).size.height - bottomMargin,
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.maybePop(context);
                              },
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Transform.scale(
                                scale: _scaleContentInAnimation.value,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 2000),
                                  transitionBuilder: (child, animation) {
                                    final tween =
                                        Tween(begin: 0.0, end: 1.0).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Interval(
                                          0.500,
                                          1.000,
                                          curve: Curves.elasticOut,
                                        ),
                                      ),
                                    );

                                    return ScaleTransition(
                                      child: child,
                                      scale: tween,
                                    );
                                  },
                                  child: _buildChild(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_disposeNow) {
          return true;
        }

        if (!_willPop) {
          _willPopNotifier.notify();
          return false;
        }

        if (_error != null) {
          setState(() {
            _error = null;
          });
          return false;
        }

        if (_paymentIntentSecret != null) {
          setState(() {
            _paymentIntentSecret = null;
            _selectedPaymentMethod = null;
          });
          return false;
        }

        if (_requiresPayment) {
          setState(() {
            _requiresPayment = false;
            _selectedPaymentMethod = null;
          });
          return false;
        }

        if (_selectedPaymentMethod != null) {
          setState(() {
            _selectedPaymentMethod = null;
          });
          return false;
        }

        await _animationController.reverse();
        return true;
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: _buildAnimation,
      ),
    );
  }
}
