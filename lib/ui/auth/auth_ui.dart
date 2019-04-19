import 'package:flutter/material.dart' hide Route;

import 'package:igflexin/router/router.dart';
import 'package:igflexin/utils/utils.dart';
import 'package:igflexin/ui/auth/intro_ui.dart';

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
                  child: RouterController.createRouter(context,
                      name: 'auth',
                      routes: [
                        Route('intro', (context) {
                          return Intro();
                        }, clearsHistory: true),
                        Route('login', (context) {
                          return LogIn();
                        }),
                        Route('create_account', (context) {
                          return CreateAccount();
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

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[LogInForm()],
    );
  }
}

class CreateAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[HelloMessageAndButtons(), PrivacyPolicy()],
    );
  }
}

class LogInForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('LOG IN TO YOUR ACCOUNT');
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
        // RouterController.withName('main').switchRoute('app');
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
        // RouterController.withName('auth').switchRoute('login');
      },
    );
  }
}
