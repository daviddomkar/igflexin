import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IGFlexinApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    return Container(
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
      child: Center(
          child: Text(
            'Hello World',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
            ),
          )
      ),
    );
  }
}