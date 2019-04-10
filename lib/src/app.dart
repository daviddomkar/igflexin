import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:igflexin/src/ui/auth_ui.dart';

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
      home: Auth(),
    );
  }
}
