import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:igflexin/utils/responsivity_utils.dart';

import 'package:url_launcher/url_launcher.dart';

class TermsOfServiceAndPrivacyPolicy extends StatelessWidget {
  TermsOfServiceAndPrivacyPolicy({Key key, this.controller})
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
              text: 'By using this app you agree with IGFlexin\'s\n',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsivityUtils.compute(14.0, context))),
          /*TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsivityUtils.compute(14.0, context)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch('https://igflexin.app/privacy-policy.html');
                }),
          TextSpan(
              text: ' and ', style: TextStyle(color: Colors.white, fontSize: ResponsivityUtils.compute(14.0, context))),*/
          TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsivityUtils.compute(14.0, context)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch('https://igflexin.app/privacy-policy.html');
                }),
          TextSpan(
              text: '.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsivityUtils.compute(14.0, context)))
        ]),
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
