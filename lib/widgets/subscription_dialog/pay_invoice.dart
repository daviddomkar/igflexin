import 'package:flutter/material.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

import '../buttons.dart';

class PayInvoice extends StatefulWidget {
  PayInvoice({
    Key key,
    this.paymentMethod,
    this.onSuccess,
    this.onError,
  }) : super(key: key);

  final PaymentMethod paymentMethod;
  final Function onSuccess;
  final Function onError;

  @override
  _PayInvoiceState createState() {
    return _PayInvoiceState();
  }
}

class _PayInvoiceState extends State<PayInvoice>
    with SingleTickerProviderStateMixin {
  SubscriptionRepository _subscriptionRepository;

  bool _processing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
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
            'Pay for subscription',
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
              'Subscription already expired and needs to be renewed for the next month with ' +
                  '${widget.paymentMethod.card.brand[0].toUpperCase()}${widget.paymentMethod.card.brand.substring(1)}' +
                  ' card **' +
                  widget.paymentMethod.card.last4 +
                  '. You will be charged ' +
                  (Provider.of<SubscriptionRepository>(context)
                              .subscription
                              .data
                              .interval ==
                          SubscriptionPlanInterval.Month
                      ? SubscriptionPlan(
                              Provider.of<SubscriptionRepository>(context)
                                  .subscription
                                  .data
                                  .type)
                          .monthlyPrice
                      : SubscriptionPlan(
                              Provider.of<SubscriptionRepository>(context)
                                  .subscription
                                  .data
                                  .type)
                          .yearlyPrice) +
                  '.',
              textAlign: TextAlign.center,
            ),
          ),
          GradientButton(
            width:
                ResponsivityUtils.compute(_processing ? 45.0 : 130.0, context),
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
                await _subscriptionRepository.payInvoice(widget.paymentMethod);
                widget.onSuccess();
              } catch (e) {
                widget.onError();
              }
            },
          ),
        ],
      ),
    );
  }
}
