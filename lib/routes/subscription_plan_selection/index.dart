import 'package:flutter/material.dart' hide Route, Title;
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/models/subscription_plan.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/routes/subscription_plan_selection/widgets/sign_out_button.dart';
import 'package:igflexin/routes/subscription_plan_selection/widgets/subscription_plans/index.dart';
import 'package:igflexin/routes/subscription_plan_selection/widgets/title.dart';
import 'package:provider/provider.dart';

class SubscriptionPlanSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: true,
      body: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: RouterAnimationController<MainRouterController>(
                    duration: const Duration(milliseconds: 2250),
                    builder: (context, controller) {
                      return SystemBarsInfoProvider(
                        builder: (context, child, systemBarsInfo, orientation) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Title(
                                controller: controller,
                                systemBarsInfo: systemBarsInfo,
                              ),
                              Center(
                                child: SubscriptionPlans(
                                  orientation: orientation,
                                  controller: controller,
                                  initialPlan: SubscriptionPlanType.values.indexOf(
                                      Provider.of<SubscriptionRepository>(context)
                                          .selectedPlanType),
                                ),
                              ),
                              SignOutButton(
                                controller: controller,
                                systemBarsInfo: systemBarsInfo,
                              ),
                            ],
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
