import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';
import 'package:igflexin/src/router.dart';

import 'package:igflexin/src/ui/auth_ui.dart';
import 'package:igflexin/src/utils.dart';

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
      home: Router(
        name: 'main',
        routes: [
          Route('auth', (context) {
            return Auth();
          }),
          Route('app', (context) {
            return Center(
              child: RaisedButton(
                highlightElevation: 0,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                color: Colors.white,
                child: Text(
                  'Klikni sem kámo',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: Utils.computeResponsivity(16.0, context),
                    color: Color.fromARGB(255, 223, 61, 139),
                  ),
                ),
                onPressed: () {
                  RouterController.withName('main').switchRoute('auth');
                },
              ),
            );
          }),
        ],
        startingRoute: 'auth',
      ),
    );
  }
}
