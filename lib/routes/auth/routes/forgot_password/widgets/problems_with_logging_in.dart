import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/routes/auth/router_controller.dart';

import 'package:igflexin/utils/responsivity_utils.dart';

import 'package:url_launcher/url_launcher.dart';

class ProblemsWithLoggingIn extends StatelessWidget {
  ProblemsWithLoggingIn({Key key, this.controller})
      : opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.500, 1.000, curve: Curves.easeOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> opacity;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Opacity(
      opacity: opacity.value,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(
            text: 'Other problems? ',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
              fontSize: ResponsivityUtils.compute(14.0, context),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Router.of<AuthRouterController>(context);
              },
          ),
        TextSpan(
            text: 'Contact us.',
            style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
                fontSize: ResponsivityUtils.compute(14.0, context)),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch('https://igflexin.app/privacy-policy.html');
              }),
        ],

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: _buildAnimation,
    );
  }
}
