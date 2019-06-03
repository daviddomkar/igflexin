import 'package:flutter/material.dart' hide Route;

import 'package:igflexin/utils/router_utils.dart';
import 'package:igflexin/utils/keyboard_utils.dart';

import 'routes/intro/index.dart';
import 'routes/log_in/index.dart';
import 'routes/sign_up/index.dart';

class Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: true,
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
                        Route('signup', (context) {
                          return SignUp();
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
