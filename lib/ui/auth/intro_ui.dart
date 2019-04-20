import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:igflexin/router/router.dart';
import 'package:igflexin/utils/utils.dart';
import 'package:igflexin/ui/shared/buttons.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouterAnimationController(
      routerName: 'auth',
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return Column(
          children: <Widget>[HelloMessageAndButtons(controller: controller), PrivacyPolicy(controller: controller)],
        );
      },
    );
  }
}

class PrivacyPolicy extends StatelessWidget {
  PrivacyPolicy({Key key, this.controller})
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
              style: TextStyle(color: Colors.white, fontSize: Utils.computeResponsivity(14.0, context))),
          TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: Utils.computeResponsivity(14.0, context)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch('https://igflexin.app/privacy-policy.htm');
                }),
          TextSpan(text: ' and ', style: TextStyle(color: Colors.white, fontSize: Utils.computeResponsivity(14.0, context))),
          TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: Utils.computeResponsivity(14.0, context)),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch('https://igflexin.app/privacy-policy.htm');
                }),
          TextSpan(text: '.', style: TextStyle(color: Colors.white, fontSize: Utils.computeResponsivity(14.0, context)))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SystemBarsMarginBox(
      statusBarMargin: false,
      child: SizedBox(
          height: Utils.computeResponsivity(50.0, context),
          child: AnimatedBuilder(
            animation: controller,
            builder: _buildAnimation,
          )),
    );
  }
}

class HelloMessageAndButtons extends StatelessWidget {
  HelloMessageAndButtons({Key key, this.controller})
      : opacityTitle = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOut),
        )),
        offsetYTitle = Tween(begin: 15.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOut),
        )),
        opacitySubtitle = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        offsetYSubtitle = Tween(begin: 15.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        scaleSignUpButton = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.400, 0.900, curve: Curves.elasticOut),
        )),
        scaleLogInButton = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.500, 1.000, curve: Curves.elasticOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> opacityTitle;
  final Animation<double> offsetYTitle;
  final Animation<double> opacitySubtitle;
  final Animation<double> offsetYSubtitle;
  final Animation<double> scaleSignUpButton;
  final Animation<double> scaleLogInButton;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
          offset: Offset(0.0, offsetYTitle.value),
          child: Opacity(
            opacity: opacityTitle.value,
            child: Text(
              'Hello.',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Utils.computeResponsivity(52.0, context),
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: Utils.computeResponsivity(24.0, context)),
          width: Utils.computeResponsivity(360.0, context),
          child: Transform.translate(
            offset: Offset(0.0, offsetYSubtitle.value),
            child: Opacity(
              opacity: opacitySubtitle.value,
              child: Text(
                'Log In and take your Instagram business to the next level.',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Utils.computeResponsivity(22.0, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Transform.scale(
          scale: scaleSignUpButton.value,
          origin: Offset(0.0, Utils.computeResponsivity(25.0, context)),
          child: Container(
            width: Utils.computeResponsivity(300.0, context),
            height: Utils.computeResponsivity(50.0, context),
            margin: EdgeInsets.only(top: Utils.computeResponsivity(70.0, context)),
            child: SignUpButton(),
          ),
        ),
        Transform.scale(
          scale: scaleLogInButton.value,
          child: Container(
            width: Utils.computeResponsivity(300.0, context),
            height: Utils.computeResponsivity(50.0, context),
            margin: EdgeInsets.only(top: Utils.computeResponsivity(10.0, context)),
            child: LogInButton(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SystemBarsInfoProvider(
        child: Center(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: Utils.computeResponsivity(0.0, context), horizontal: Utils.computeResponsivity(40.0, context)),
              child: AnimatedBuilder(animation: controller, builder: _buildAnimation)),
        ),
        builder: (context, child, systemBarsInfo, orientation) {
          return Expanded(
            child: Container(
                constraints: BoxConstraints.expand(height: Utils.computeResponsivity(480.0, context)),
                margin: EdgeInsets.only(
                    top: (orientation == Orientation.portrait ? Utils.computeResponsivity(50.0, context) : 0.0) + systemBarsInfo.navigationBarHeight),
                child: child),
          );
        });
  }
}

class SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CurvedWhiteBorderedTransparentButton(
      child: Text(
        "I am new to this app",
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: Utils.computeResponsivity(16.0, context),
          color: Colors.white,
        ),
      ),
      onPressed: () {
        RouterController.of(context, 'main').switchRoute('main', 'app');
      },
    );
  }
}

class LogInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CurvedWhiteButton(
      child: Text(
        'I have an account already',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: Utils.computeResponsivity(16.0, context),
          color: Color.fromARGB(255, 223, 61, 139),
        ),
      ),
      onPressed: () {
        RouterController.of(context, 'auth').switchRoute('auth', 'login');
      },
    );
  }
}
