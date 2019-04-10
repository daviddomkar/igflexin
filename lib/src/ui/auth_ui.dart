import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:igflexin/src/utils.dart';

class Auth extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            colors: [
              Color.fromARGB(255, 223, 61, 139),
              Color.fromARGB(255, 255, 161, 94)
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntroScreen()
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TopMessage(),
        Intro(),
        PrivacyPolicy()
      ],
    );
  }
}

class TopMessage extends StatefulWidget {
  @override
  _TopMessage createState() => _TopMessage();
}

class _TopMessage extends State<TopMessage> with SingleTickerProviderStateMixin {

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
      curve: new Interval(
        0.150,
        1.000,
        curve: Curves.fastLinearToSlowEaseIn
      ),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Opacity(
      opacity: _opacity.value,
      child: Text(
        'Reach Instagram popularity rapidly!',
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: Utils.computeResponsivity(14.0, context),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center (
      child: Padding( 
        padding: EdgeInsets.symmetric(vertical: Utils.computeResponsivity(50.0, context)),
        child: AnimatedBuilder(
          animation: _controller,
          builder: _buildAnimation,
        ),
      ),
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
      curve: new Interval(
        0.150,
        1.000,
        curve: Curves.fastLinearToSlowEaseIn
      ),
    ));


    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Opacity(
      opacity: _opacity.value,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'By using this app, you agree with IGFlexin\'s',
              style: TextStyle(color: Colors.white)
            ),
            TextSpan(
              text: '\nPrivacy Policy',
              style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () { launch('https://igflexin.app/privacy-policy.htm'); }
            ),
            TextSpan(
              text: ' and ',
              style: TextStyle(color: Colors.white)
            ),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () { launch('https://igflexin.app/privacy-policy.htm'); }
            ),
            TextSpan(
              text: '.',
              style: TextStyle(color: Colors.white)
            )
          ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Utils.computeResponsivity(50.0, context)),
      child: AnimatedBuilder(
        animation: _controller,
        builder: _buildAnimation,
      ),
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
      curve: new Interval(
        0.150,
        1.000,
        curve: Curves.fastLinearToSlowEaseIn
      ),
    ));

    _offsetY = Tween(begin: 5.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: new Interval(
        0.150,
        1.000,
        curve: Curves.fastLinearToSlowEaseIn
      ),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Transform.translate(
          offset: Offset(0.0, _offsetY.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Text(
              'Hi,',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: Utils.computeResponsivity(40.0, context),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container (
          margin: EdgeInsets.only(top: Utils.computeResponsivity(15.0, context)),
          width: Utils.computeResponsivity(300.0, context),
          child: Transform.translate(
            offset: Offset(0.0, _offsetY.value),
              child: Opacity(
                opacity: _opacity.value, 
                child: Text (
                'Do you want your business to become more visible or just wanna get some fame on Instagram?',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: Utils.computeResponsivity(32.0, context),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Container (
          margin: EdgeInsets.only(top: Utils.computeResponsivity(15.0, context)),
          width: Utils.computeResponsivity(290.0, context),
          child: Transform.translate(
            offset: Offset(0.0, _offsetY.value),
              child: Opacity(
                opacity: _opacity.value, 
                child: Text(
                "Doesn't matter, our app can help you.",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: Utils.computeResponsivity(25.0, context),
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
            margin: EdgeInsets.only(top: Utils.computeResponsivity(30.0, context)),
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
    return Center(
      child: Padding(
        padding: EdgeInsets.only(right: Utils.computeResponsivity(40.0, context), left: Utils.computeResponsivity(40.0, context)),
        child: AnimatedBuilder(
          animation: _controller,
          builder: _buildAnimation,
        )
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return RaisedButton ( 
      highlightElevation: 0,  
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0), side: BorderSide(
        color: Colors.white,
      )),
      color: Colors.transparent,
      child: Text (
        'Sign up',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: Utils.computeResponsivity(16.0, context),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ), onPressed: () {
        // TODO onPressed
      },
    );
  }
}

class LogInButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {;
    return RaisedButton ( 
      highlightElevation: 0,  
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      color: Colors.white,
      child: Text (
        'Log In',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: Utils.computeResponsivity(16.0, context),
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 223, 61, 139),
        ),
      ), onPressed: () {
        // TODO onPressed
      },
    );
  }
}