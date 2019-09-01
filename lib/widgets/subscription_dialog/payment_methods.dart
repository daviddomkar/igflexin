import 'package:flutter/material.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/subscription_dialog/add_new_card.dart';
import 'package:igflexin/widgets/subscription_dialog/index.dart';
import 'package:provider/provider.dart';

import '../buttons.dart';

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({
    Key key,
    this.title,
    this.willPop,
    this.onPaymentMethodSelected,
    this.willPopNotifier,
  }) : super(key: key);

  final String title;
  final WillPopNotifier willPopNotifier;
  final Function(bool) willPop;
  final Function(PaymentMethod) onPaymentMethodSelected;

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods>
    with SingleTickerProviderStateMixin {
  SubscriptionRepository _subscriptionRepository;
  List<PaymentMethod> _paymentMethods;
  PaymentMethod _paymentMethodToRemove;

  AnimationController _animationController;

  Animation<double> _cornerRadius;
  Animation<double> _contentOpacity;
  Animation<double> _width;
  Animation<double> _height;

  bool _error = false;
  bool _removing = false;
  bool _addNewCardAnimating = false;
  bool _addNewCardDisplayed = false;

  @override
  void initState() {
    super.initState();

    widget.willPopNotifier.addListener(_onWillPop);

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

    _fetchPaymentMethods();

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
            begin: ResponsivityUtils.compute(170.0, context),
            end: MediaQuery.of(context).size.height)
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: new Interval(0.500, 1.000, curve: Curves.easeInExpo),
      ),
    );
  }

  void _onWillPop() {
    if (_paymentMethodToRemove != null && !_removing) {
      if (_error) {
        setState(() {
          _error = false;
        });
      } else {
        setState(() {
          _paymentMethodToRemove = null;
          widget.willPop(true);
        });
      }
    } else if (_addNewCardAnimating) {
      _animationController.reverse().then((_) {
        _addNewCardAnimating = false;
        widget.willPop(true);
      });
    }
  }

  @override
  void dispose() {
    widget.willPop(true);
    widget.willPopNotifier.removeListener(_onWillPop);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchPaymentMethodsUnsafe() async {
    final paymentMethods = await _subscriptionRepository.getPaymentMethods();

    setState(() {
      _paymentMethods = paymentMethods;
    });
  }

  Future<void> _fetchPaymentMethods() async {
    if (_paymentMethods != null) return;

    try {
      final paymentMethods = await _subscriptionRepository.getPaymentMethods();

      setState(() {
        _paymentMethods = paymentMethods;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  Widget _buildChild(BuildContext context) {
    if (_paymentMethodToRemove != null) {
      if (_error) {
        return Container(
          key: ValueKey(3),
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
                  'An error occured. Check your connection!',
                  textAlign: TextAlign.center,
                ),
              ),
              GradientButton(
                width: ResponsivityUtils.compute(130.0, context),
                height: ResponsivityUtils.compute(40.0, context),
                child: Text(
                  'Ok',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    _error = false;
                    _removing = false;
                  });
                },
              ),
            ],
          ),
        );
      } else {
        return Container(
          key: ValueKey(0),
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
                'Remove card',
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
                  '${_paymentMethodToRemove.card.brand[0].toUpperCase()}${_paymentMethodToRemove.card.brand.substring(1)}' +
                      ' card' +
                      ' **' +
                      _paymentMethodToRemove.card.last4 +
                      ' will be removed.',
                  textAlign: TextAlign.center,
                ),
              ),
              GradientButton(
                width: ResponsivityUtils.compute(
                    _removing ? 45.0 : 130.0, context),
                height: ResponsivityUtils.compute(45.0, context),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.ease,
                        opacity: !_removing ? 1.0 : 0.0,
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
                        opacity: _removing ? 1.0 : 0.0,
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
                  if (_removing) return;

                  setState(() {
                    _removing = true;
                  });

                  try {
                    await _subscriptionRepository
                        .removePaymentMethod(_paymentMethodToRemove);
                    widget.willPop(true);
                    setState(() {
                      _removing = false;
                      _paymentMethodToRemove = null;
                      _paymentMethods = null;
                    });
                    _fetchPaymentMethods();
                  } catch (e) {
                    setState(() {
                      _error = true;
                    });
                  }
                },
              ),
            ],
          ),
        );
      }
    } else if (_paymentMethods != null) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            key: ValueKey(1),
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
                    widget.title ?? 'Payment methods',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsivityUtils.compute(23.0, context),
                      fontWeight: FontWeight.bold,
                      color:
                          _subscriptionRepository.planTheme.gradientStartColor,
                    ),
                  ),
                  Container(
                    height: ResponsivityUtils.compute(94.0, context),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                          vertical: ResponsivityUtils.compute(10.0, context)),
                      itemCount: _paymentMethods.length + 1,
                      itemBuilder: (context, index) {
                        if (index != _paymentMethods.length) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                              vertical: ResponsivityUtils.compute(2.0, context),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: ResponsivityUtils.compute(
                                        50.0, context),
                                    child: CurvedTransparentButton(
                                      child: Row(
                                        children: [
                                          Icon(Icons.credit_card),
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: ResponsivityUtils.compute(
                                                  10.0, context),
                                            ),
                                            child: Text(
                                              '${_paymentMethods[index].card.brand[0].toUpperCase()}${_paymentMethods[index].card.brand.substring(1)}' +
                                                  ' card' +
                                                  ' **' +
                                                  _paymentMethods[index]
                                                      .card
                                                      .last4,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: widget
                                                  .onPaymentMethodSelected !=
                                              null
                                          ? () {
                                              widget.onPaymentMethodSelected(
                                                  _paymentMethods[index]);
                                            }
                                          : null,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    height: ResponsivityUtils.compute(
                                        50.0, context),
                                    child: FloatingActionButton(
                                      elevation: 0,
                                      focusElevation: 0,
                                      highlightElevation: 0,
                                      disabledElevation: 0,
                                      backgroundColor: Colors.transparent,
                                      mini: true,
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                        size: ResponsivityUtils.compute(
                                            24.0, context),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          widget.willPop(false);
                                          _paymentMethodToRemove =
                                              _paymentMethods[index];
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            margin: EdgeInsets.symmetric(
                              vertical: ResponsivityUtils.compute(2.0, context),
                            ),
                            child: Container(
                              height: ResponsivityUtils.compute(50.0, context),
                              child: CurvedTransparentButton(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: _subscriptionRepository
                                          .planTheme.gradientEndColor,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: ResponsivityUtils.compute(
                                            10.0, context),
                                      ),
                                      child: Text(
                                        'Add new card',
                                        style: TextStyle(
                                          color: _subscriptionRepository
                                              .planTheme.gradientEndColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  if (_addNewCardAnimating) return;

                                  _addNewCardAnimating = true;
                                  widget.willPop(false);
                                  _animationController.forward().then((_) {
                                    _addNewCardAnimating = false;
                                    setState(() {
                                      _addNewCardDisplayed = true;
                                    });
                                  });
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (_error) {
      return Container(
        key: ValueKey(2),
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
                'An error occured. Check your connection!',
                textAlign: TextAlign.center,
              ),
            ),
            GradientButton(
              width: ResponsivityUtils.compute(130.0, context),
              height: ResponsivityUtils.compute(40.0, context),
              child: Text(
                'Retry',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  _error = false;
                });
                _fetchPaymentMethods();
              },
            ),
          ],
        ),
      );
    } else {
      return CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          _subscriptionRepository.planTheme.gradientStartColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_addNewCardDisplayed) {
      return AddNewCard(
        willPopNotifier: widget.willPopNotifier,
        refreshPaymentMethods: _fetchPaymentMethodsUnsafe,
        onDisposeReady: () {
          setState(() {
            _addNewCardDisplayed = false;
          });
          _addNewCardAnimating = true;
          _animationController.reverse().then((_) {
            _addNewCardAnimating = false;
            widget.willPop(true);
          });
        },
      );
    } else {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 2000),
        transitionBuilder: (child, animation) {
          final tween = Tween(begin: 0.0, end: 1.0).animate(
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
      );
    }
  }
}
