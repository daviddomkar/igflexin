import 'package:flutter/material.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/alert_dialog.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class CardSelectionDialog extends StatefulWidget {
  @override
  _CardSelectionDialogState createState() {
    return _CardSelectionDialogState();
  }
}

class _CardSelectionDialogState extends State<CardSelectionDialog>
    with SingleTickerProviderStateMixin {
  SubscriptionRepository _subscriptionRepository;

  AnimationController _controller;

  Animation<double> _scale;

  List<PaymentMethod> _paymentMethods;
  bool _networkError = false;

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

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
      return RoundedAlertDialog(
        title: Text(
          'Select your card',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsivityUtils.compute(23.0, context),
            fontWeight: FontWeight.bold,
            color: Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
          ),
        ),
        content: _paymentMethods.isEmpty
            ? Text(
                'tututuut hehehehhehehehe výběr karet tady bude xd.',
                textAlign: TextAlign.center,
              )
            : Text(
                'heheh',
                textAlign: TextAlign.center,
              ),
        actions: [
          GradientButton(
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
        ],
      );
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
    return AnimatedBuilder(
      animation: _controller,
      builder: _buildAnimation,
    );
  }
}
