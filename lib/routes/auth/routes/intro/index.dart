import 'package:flutter/material.dart' hide Title;

import 'package:igflexin/router/router.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

import 'package:flutter_system_bars/flutter_system_bars.dart';

import 'widgets/title.dart';
import 'widgets/subtitle.dart';
import 'widgets/terms_of_service_and_privacy_policy.dart';
import 'widgets/sign_up_button.dart';
import 'widgets/log_in_button.dart';

const double _BOTTOM_HEIGHT_ = 40.0;

class Intro extends StatelessWidget {
  Widget build(BuildContext context) {
    return RouterAnimationController(
      routerName: 'auth',
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return SystemBarsInfoProvider(builder: (context, child, systemBarsInfo, orientation) {
          return _Intro(controller, systemBarsInfo, orientation);
        });
      },
    );
  }
}

class _Intro extends StatelessWidget {
  _Intro(this.controller, this.systemBarsInfo, this.orientation);

  final AnimationController controller;
  final SystemBarsInfo systemBarsInfo;
  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            constraints: orientation == Orientation.landscape
                ? BoxConstraints.expand(
                    height: ResponsivityUtils.compute(480, context),
                  )
                : BoxConstraints(),
            margin: EdgeInsets.only(
              top: (orientation == Orientation.portrait
                  ? systemBarsInfo.navigationBarHeight + ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context)
                  : ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context)),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsivityUtils.compute(40.0, context)),
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
                ),
              ),
            ),
          ),
        ),
        Container(
          height: ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context),
          margin:
              EdgeInsets.only(bottom: orientation == Orientation.portrait ? systemBarsInfo.navigationBarHeight : 0.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: TermsOfServiceAndPrivacyPolicy(controller: controller),
          ),
        ),
      ],
    );
  }
}
