import 'package:flutter/material.dart' hide Title;
import 'package:igflexin/routes/auth/router_controller.dart';
import 'package:igflexin/routes/auth/routes/forgot_password/widgets/forgot_password_form/index.dart';
import 'package:igflexin/utils/keyboard_utils.dart';

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

import 'package:flutter_system_bars/flutter_system_bars.dart';

import 'widgets/problems_with_logging_in.dart';

const double _BOTTOM_HEIGHT_ = 60.0;

class ForgotPassword extends StatelessWidget {
  Widget build(BuildContext context) {
    return RouterAnimationController<AuthRouterController>(
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return SystemBarsInfoProvider(builder: (context, child, systemBarsInfo, orientation) {
          return _ForgotPassword(controller, systemBarsInfo, orientation);
        });
      },
    );
  }
}

class _ForgotPassword extends StatelessWidget {
  _ForgotPassword(this.controller, this.systemBarsInfo, this.orientation);

  final AnimationController controller;
  final SystemBarsInfo systemBarsInfo;
  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: orientation == Orientation.landscape ? EdgeInsets.symmetric(vertical: systemBarsInfo.navigationBarHeight) : EdgeInsets.zero,
      child: Column(
        children: [
          Expanded(
            child: KeyboardInfoProvider(
              builder: (context, info) {
                return Container(
                  constraints: orientation == Orientation.landscape
                      ? BoxConstraints.expand(
                          height: ResponsivityUtils.compute(360, context),
                        )
                      : BoxConstraints(),
                  margin: EdgeInsets.only(
                      top: ((orientation == Orientation.portrait &&
                              info.offsetY <= systemBarsInfo.navigationBarHeight
                          ? systemBarsInfo.navigationBarHeight +
                              ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context)
                          : 0.0)),
                      bottom: info.offsetY - ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context) > 0
                          ? info.offsetY -
                              (ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context) +
                                  (orientation == Orientation.portrait
                                      ? systemBarsInfo.navigationBarHeight
                                      : 0.0))
                          : 0.0),
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: ResponsivityUtils.compute(40.0, context)),
                      child: ForgotPasswordForm(controller: controller),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context),
            margin: EdgeInsets.only(
                bottom:
                orientation == Orientation.portrait ? systemBarsInfo.navigationBarHeight : 0.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: ProblemsWithLoggingIn(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}
