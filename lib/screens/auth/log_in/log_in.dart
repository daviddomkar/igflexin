import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/widgets/icons/auth_provider_icons.dart';

import 'package:igflexin/router/router.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouterAnimationController(
      routerName: 'auth',
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return Column(children: <Widget>[
          SystemBarsInfoProvider(
            child: Center(
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: ResponsivityUtils.compute(0.0, context), horizontal: ResponsivityUtils.compute(40.0, context)),
                  child: LogInForm()),
            ),
            builder: (context, child, systemBarsInfo, orientation) {
              return Expanded(
                child: Container(
                    constraints: orientation == Orientation.landscape
                        ? BoxConstraints.expand(height: ResponsivityUtils.compute(200.0, context))
                        : BoxConstraints(),
                    margin: EdgeInsets.only(
                        top: (orientation == Orientation.portrait ? ResponsivityUtils.compute(36.0 + 80.0, context) : 0.0) +
                            systemBarsInfo.navigationBarHeight),
                    child: child),
              );
            },
          ),
          SystemBarsMarginBox(
            statusBarMargin: false,
            child: SizedBox(
              height: ResponsivityUtils.compute(36.0 + 80.0, context),
              child: Column(
                children: [AuthProviderIconsBar(), ProblemsWithLoggingIn(controller: controller)],
              ),
            ),
          )
        ]);
      },
    );
  }
}

class LogInForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('LOG IN TO YOUR ACCOUNT'),
        TextField(
          decoration: InputDecoration(border: InputBorder.none, hintText: 'Please enter a search term'),
        ),
        TextField(
          decoration: InputDecoration(border: InputBorder.none, hintText: 'Please enter a search term'),
        )
      ],
    );
  }
}

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
          style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: ResponsivityUtils.compute(14.0, context)),
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

class AuthProviderIconsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsivityUtils.compute(250.0, context),
      height: ResponsivityUtils.compute(80.0, context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AuthProviderIcons.google,
            color: Colors.white,
            size: ResponsivityUtils.compute(40.0, context),
          ),
          Icon(
            AuthProviderIcons.instagram,
            color: Colors.white,
            size: ResponsivityUtils.compute(40.0, context),
          ),
          Icon(
            AuthProviderIcons.facebook,
            color: Colors.white,
            size: ResponsivityUtils.compute(40.0, context),
          ),
        ],
      ),
    );
  }

  AuthProviderIconsBar();
}
