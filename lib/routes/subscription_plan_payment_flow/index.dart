import 'package:flutter/material.dart' hide Title;
import 'package:flutter/painting.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/apple_pay_button.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/credit_or_debit_card_button.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/google_pay_button.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/summary.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/title.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class SubscriptionPlanPaymentFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: systemBarsInfo.hasSoftwareNavigationBar
                                    ? systemBarsInfo.navigationBarHeight
                                    : systemBarsInfo.statusBarHeight),
                            child: _SubscriptionPaymentFlow(
                              controller: controller,
                            ),
                          );
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

class _SubscriptionPaymentFlow extends StatelessWidget {
  const _SubscriptionPaymentFlow({Key key, this.controller}) : super(key: key);

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Title(
          controller: controller,
          interval: Provider.of<SubscriptionRepository>(context).selectedPlanInterval,
          type: Provider.of<SubscriptionRepository>(context).selectedPlanType,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsivityUtils.compute(40.0, context),
            horizontal: ResponsivityUtils.compute(50.0, context),
          ),
          child: Summary(
            controller: controller,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: ResponsivityUtils.compute(5.0, context)),
          child: CreditOrDebitCardButton(
            controller: controller,
          ),
        ),
        if (Provider.of<SubscriptionRepository>(context).isApplePayAvailable) ...{
          Padding(
            padding: EdgeInsets.only(top: ResponsivityUtils.compute(5.0, context)),
            child: ApplePayButton(
              controller: controller,
            ),
          ),
        },
        if (Provider.of<SubscriptionRepository>(context).isGooglePayAvailable) ...{
          Padding(
            padding: EdgeInsets.only(top: ResponsivityUtils.compute(5.0, context)),
            child: GooglePayButton(
              controller: controller,
            ),
          ),
        }
      ],
    );
  }
}
