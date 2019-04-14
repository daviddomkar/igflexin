import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:igflexin/src/router.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';

import 'package:igflexin/src/utils.dart';

class Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            colors: [Color.fromARGB(255, 223, 61, 139), Color.fromARGB(255, 255, 161, 94)],
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Router(
                      name: 'auth',
                      routes: [
                        Route('intro', (context) {
                          return IntroScreen();
                        }, clearsHistory: true),
                        Route('login', (context) {
                          return LogInScreen();
                        }),
                        Route('create_account', (context) {
                          return CreateAccountScreen();
                        })
                      ],
                      startingRoute: 'intro'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[Intro(), PrivacyPolicy()],
    );
  }
}

class LogInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[Intro()],
    );
  }
}

class CreateAccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[Intro(), PrivacyPolicy()],
    );
  }
}

class Intro extends StatefulWidget {
  @override
  _Intro createState() => _Intro();
}

class _Intro extends State<Intro> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _opacity;
  Animation<double> _offsetY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3450),
      vsync: this,
    );

    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.150, 1.000, curve: Curves.fastLinearToSlowEaseIn),
    ));

    _offsetY = Tween(begin: 5.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.150, 1.000, curve: Curves.fastLinearToSlowEaseIn),
    ));

    _controller.forward();
    RouterController.withName('auth').registerAnimationController(_controller);
  }

  @override
  void dispose() {
    RouterController.withName('auth').unregisterAnimationController(_controller);
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
          offset: Offset(0.0, _offsetY.value),
          child: Opacity(
            opacity: _opacity.value,
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
            offset: Offset(0.0, _offsetY.value),
            child: Opacity(
              opacity: _opacity.value,
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
        Opacity(
          opacity: _opacity.value,
          child: Container(
            width: Utils.computeResponsivity(300.0, context),
            height: Utils.computeResponsivity(50.0, context),
            margin: EdgeInsets.only(top: Utils.computeResponsivity(70.0, context)),
            child: SignUpButton(),
          ),
        ),
        Opacity(
          opacity: _opacity.value,
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
              padding: EdgeInsets.symmetric(
                  vertical: Utils.computeResponsivity(0.0, context),
                  horizontal: Utils.computeResponsivity(40.0, context)),
              child: AnimatedBuilder(animation: _controller, builder: _buildAnimation)),
        ),
        builder: (context, child, systemBarsInfo, orientation) {
          return Expanded(
            child: Container(
                constraints:
                    BoxConstraints.expand(height: Utils.computeResponsivity(480.0, context)),
                margin: EdgeInsets.only(
                    top: (orientation == Orientation.portrait
                            ? Utils.computeResponsivity(50.0, context)
                            : 0.0) +
                        systemBarsInfo.navigationBarHeight),
                child: child),
          );
        });
  }
}

class SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      highlightElevation: 0,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
          side: BorderSide(
            color: Colors.white,
          )),
      color: Colors.transparent,
      child: Text(
        "I am new to this app",
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: Utils.computeResponsivity(16.0, context),
          color: Colors.white,
        ),
      ),
      onPressed: () {
        RouterController.withName('main').switchRoute('app');
      },
    );
  }
}

class LogInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      highlightElevation: 0,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      color: Colors.white,
      child: Text(
        'I have an account already',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: Utils.computeResponsivity(16.0, context),
          color: Color.fromARGB(255, 223, 61, 139),
        ),
      ),
      onPressed: () {
        RouterController.withName('auth').switchRoute('login');
      },
    );
  }
}

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicy createState() => _PrivacyPolicy();
}

class _PrivacyPolicy extends State<PrivacyPolicy> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3450),
      vsync: this,
    );

    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.150, 1.000, curve: Curves.fastLinearToSlowEaseIn),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Opacity(
      opacity: _opacity.value,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(
              text: 'By using this app you agree with IGFlexin\'s\n',
              style: TextStyle(
                  color: Colors.white, fontSize: Utils.computeResponsivity(14.0, context))),
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
          TextSpan(
              text: ' and ',
              style: TextStyle(
                  color: Colors.white, fontSize: Utils.computeResponsivity(14.0, context))),
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
          TextSpan(
              text: '.',
              style: TextStyle(
                  color: Colors.white, fontSize: Utils.computeResponsivity(14.0, context)))
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
            animation: _controller,
            builder: _buildAnimation,
          )),
    );
  }
}
