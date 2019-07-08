import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/models/subscription_plan.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class SubscriptionPlanPaymentFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(Provider.of<SubscriptionRepository>(context).selectedPlanType);
    print(Provider.of<SubscriptionRepository>(context).selectedPlanInterval);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            colors: [
              Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
              Provider.of<SubscriptionRepository>(context).planTheme.gradientEndColor,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: RouterAnimationController<MainRouterController>(
                    duration: const Duration(milliseconds: 2000),
                    builder: (context, controller) {
                      return SystemBarsInfoProvider(
                        builder: (context, child, systemBarsInfo, orientation) {
                          return _SubscriptionPaymentFlow();
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SubscriptionPaymentFlow extends StatefulWidget {
  const _SubscriptionPaymentFlow({Key key, this.systemBarsInfo}) : super(key: key);

  final SystemBarsInfo systemBarsInfo;

  @override
  __SubscriptionPaymentFlowState createState() {
    return __SubscriptionPaymentFlowState();
  }
}

class __SubscriptionPaymentFlowState extends State<_SubscriptionPaymentFlow> {
  SubscriptionRepository _subscriptionRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    SubscriptionPlan plan = SubscriptionPlan(_subscriptionRepository.selectedPlanType);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          getStringFromSubscriptionPlanInterval(_subscriptionRepository.selectedPlanInterval)
                  .toUpperCase() +
              'LY ' +
              getStringFromSubscriptionPlanType(_subscriptionRepository.selectedPlanType)
                  .toUpperCase()
                  .replaceAll(new RegExp(r'_'), ' ') +
              ' PLAN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: ResponsivityUtils.compute(23.0, context),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsivityUtils.compute(40.0, context),
            horizontal: ResponsivityUtils.compute(50.0, context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsivityUtils.compute(6.0, context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'First 7 days:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(18.0, context),
                      ),
                    ),
                    Text(
                      'FREE',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(18.0, context),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsivityUtils.compute(6.0, context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Then for:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(18.0, context),
                      ),
                    ),
                    Text(
                      _subscriptionRepository.selectedPlanInterval == SubscriptionPlanInterval.Month
                          ? plan.monthlyPrice
                          : plan.yearlyPrice,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(18.0, context),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsivityUtils.compute(6.0, context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount coupon:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsivityUtils.compute(18.0, context),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      opacity: 0.8,
                      child: Text(
                        'Add coupon',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsivityUtils.compute(18.0, context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: ResponsivityUtils.compute(5.0, context)),
          child: Container(
            width: ResponsivityUtils.compute(300.0, context),
            height: ResponsivityUtils.compute(50.0, context),
            child: CurvedWhiteBorderedTransparentButton(
              child: Text(
                'Buy with Credit or Debit card',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _subscriptionRepository.getCustomer();
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: ResponsivityUtils.compute(5.0, context)),
          child: Container(
            width: ResponsivityUtils.compute(300.0, context),
            height: ResponsivityUtils.compute(50.0, context),
            child: CurvedWhiteButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Buy with',
                  ),
                  Platform.isIOS
                      ? Container(
                          margin: EdgeInsets.only(left: ResponsivityUtils.compute(3.0, context)),
                          child: Image.asset(
                            'assets/apple_pay.png',
                            height: ResponsivityUtils.compute(20.0, context),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(left: ResponsivityUtils.compute(3.0, context)),
                          child: Image.asset(
                            'assets/google_pay.png',
                            height: ResponsivityUtils.compute(20.0, context),
                          ),
                        ),
                ],
              ),
              onPressed: () {
                _subscriptionRepository.endCustomerSession();
              },
            ),
          ),
        ),
      ],
    );
  }
}
