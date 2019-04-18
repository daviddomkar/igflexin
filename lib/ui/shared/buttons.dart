import 'package:flutter/material.dart';
import 'package:igflexin/utils/utils.dart';

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
