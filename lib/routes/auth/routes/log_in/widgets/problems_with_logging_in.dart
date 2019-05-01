import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
        text: TextSpan(
          text: 'Problems with logging in?',
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
            fontSize: ResponsivityUtils.compute(14.0, context),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launch('https://example.com'); //TODO tady to musí něco udělat normálního xd
            },
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
