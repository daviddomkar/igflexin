import 'package:flutter/material.dart' hide Route;
import 'package:igflexin/router/router.dart';

import 'package:igflexin/utils/responsivity_utils.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            fontSize: ResponsivityUtils.compute(16.0, context),
            color: Color.fromARGB(255, 223, 61, 139),
          ),
        ),
        onPressed: () {
          RouterController.of(context, 'main').switchRoute('main', 'auth');
        },
      ),
    );
  }
}
