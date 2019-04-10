import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:igflexin/src/utils.dart';

class Auth extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Center (
                      child: Padding( 
                        padding: EdgeInsets.symmetric(vertical: Utils.computeResponsivity(50.0, devicePixelRatio)),
                        child: Text(
                          'Reach Instagram popularity rapidly!',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: Utils.computeResponsivity(14.0, devicePixelRatio),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ),
                    ),
                    Welcome(),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: Utils.computeResponsivity(50.0, devicePixelRatio)),
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
                              text: '.',
                              style: TextStyle(color: Colors.white)
                            )
                          ]
                        ),
                      ),
                      /*child: Text(
                        'By using this app you agree with TOS.',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: Utils.computeResponsivity(14.0, devicePixelRatio),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),*/
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Welcome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(right: Utils.computeResponsivity(40.0, devicePixelRatio), left: Utils.computeResponsivity(40.0, devicePixelRatio)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Hi,',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: Utils.computeResponsivity(40.0, devicePixelRatio),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Container (
              margin: EdgeInsets.only(top: Utils.computeResponsivity(15.0, devicePixelRatio)),
              width: Utils.computeResponsivity(300.0, devicePixelRatio),
              child: Text (
                'Do you want your business to become more visible or just wanna get some fame on Instagram?',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: Utils.computeResponsivity(32.0, devicePixelRatio),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container (
              margin: EdgeInsets.only(top: Utils.computeResponsivity(15.0, devicePixelRatio)),
              width: Utils.computeResponsivity(290.0, devicePixelRatio),
              child: Text(
                "Doesn't matter, our app can help you.",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: Utils.computeResponsivity(25.0, devicePixelRatio),
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: Utils.computeResponsivity(300.0, devicePixelRatio),
              height: Utils.computeResponsivity(50.0, devicePixelRatio),
              margin: EdgeInsets.only(top: Utils.computeResponsivity(30.0, devicePixelRatio)),
              child: SignUpButton(),
            ),
            Container(
              width: Utils.computeResponsivity(300.0, devicePixelRatio),
              height: Utils.computeResponsivity(50.0, devicePixelRatio),
              margin: EdgeInsets.only(top: Utils.computeResponsivity(10.0, devicePixelRatio)),
              child: LogInButton(),
            ),
          ],
        )
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

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
          fontSize: Utils.computeResponsivity(16.0, devicePixelRatio),
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
  Widget build(BuildContext context) {

    var queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

    return RaisedButton ( 
      highlightElevation: 0,  
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      color: Colors.white,
      child: Text (
        'Log In',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: Utils.computeResponsivity(16.0, devicePixelRatio),
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 223, 61, 139),
        ),
      ), onPressed: () {
        // TODO onPressed
      },
    );
  }
}