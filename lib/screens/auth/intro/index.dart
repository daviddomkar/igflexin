import 'package:flutter/material.dart' hide Title;

import 'package:igflexin/router/router.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

import 'package:flutter_system_bars/flutter_system_bars.dart';

import 'package:igflexin/screens/auth/intro/widgets/title.dart';
import 'package:igflexin/screens/auth/intro/widgets/subtitle.dart';
import 'package:igflexin/screens/auth/intro/widgets/terms_of_service_and_privacy_policy.dart';
import 'package:igflexin/screens/auth/intro/widgets/sign_up_button.dart';
import 'package:igflexin/screens/auth/intro/widgets/log_in_button.dart';

class Intro extends StatelessWidget {
  Widget build(BuildContext context) {
    return RouterAnimationController(
      routerName: 'auth',
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return Column(
          children: <Widget>[
            SystemBarsInfoProvider(builder: (context, child, systemBarsInfo, orientation) {
              return Expanded(
                child: Container(
                  constraints: orientation == Orientation.landscape
                      ? BoxConstraints.expand(height: ResponsivityUtils.compute(480.0, context))
                      : BoxConstraints(),
                  margin: EdgeInsets.only(
                      top: (orientation == Orientation.portrait ? ResponsivityUtils.compute(50.0, context) : 0.0) +
                          systemBarsInfo.navigationBarHeight),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: ResponsivityUtils.compute(0.0, context),
                            horizontal: ResponsivityUtils.compute(40.0, context)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Title(controller: controller),
                            Container(
                              margin: EdgeInsets.only(top: ResponsivityUtils.compute(24.0, context)),
                              width: ResponsivityUtils.compute(360.0, context),
                              child: Subtitle(controller: controller),
                            ),
                            SignUpButton(controller: controller),
                            LogInButton(controller: controller)
                          ],
                        )),
                  ),
                ),
              );
            }),
            SystemBarsMarginBox(
              statusBarMargin: false,
              child: SizedBox(
                height: ResponsivityUtils.compute(50.0, context),
                child: TermsOfServiceAndPrivacyPolicy(controller: controller),
              ),
            )
          ],
        );
      },
    );
  }
}
