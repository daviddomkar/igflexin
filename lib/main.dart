import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';

import 'package:igflexin/utils/router_utils.dart';

import 'package:igflexin/routes/auth/index.dart';
import 'package:igflexin/routes/app/index.dart';

void main() => runApp(IGFlexinApp());

class IGFlexinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'LatoLatin',
        primaryColor: Color.fromARGB(255, 223, 61, 139),
        accentColor: Color.fromARGB(255, 255, 161, 94),
      ),
      home: RouterController.create(
        context,
        child: RouterController.createRouter(
          context,
          name: 'main',
          routes: [
            Route('auth', (context) {
              return Auth();
            }, clearsHistory: true),
            Route('purchase', (context) {
              return Auth();
            }, clearsHistory: true),
            Route('app', (context) {
              return App();
            }, clearsHistory: true),
          ],
          startingRoute: 'entry',
        ),
      ),
    );
  }
}
