import 'package:flutter/material.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/router_controller.dart';
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
  @override
  __SubscriptionPaymentFlowState createState() {
    return __SubscriptionPaymentFlowState();
  }
}

class __SubscriptionPaymentFlowState extends State<_SubscriptionPaymentFlow> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text('beginSession'),
        onPressed: () {
          Provider.of<SubscriptionRepository>(context).beginCustomerSession();
        },
      ),
    );
  }
}
