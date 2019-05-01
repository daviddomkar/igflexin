import 'package:flutter/material.dart' hide Title;

import 'package:igflexin/router/router.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

import 'package:flutter_system_bars/flutter_system_bars.dart';

import 'widgets/log_in_form/index.dart';
import 'widgets/auth_provider_icons_bar.dart';
import 'widgets/problems_with_logging_in.dart';

const double _BOTTOM_HEIGHT_ = 96.0;

class LogIn extends StatelessWidget {
  Widget build(BuildContext context) {
    return RouterAnimationController(
      routerName: 'auth',
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return SystemBarsInfoProvider(builder: (context, child, systemBarsInfo, orientation) {
          return _LogIn(controller, systemBarsInfo, orientation);
        });
      },
    );
  }
}

class _LogIn extends StatelessWidget {
  _LogIn(this.controller, this.systemBarsInfo, this.orientation);

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
                child: LogInForm(),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AuthProviderIconsBar(controller: controller),
                ProblemsWithLoggingIn(controller: controller),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
