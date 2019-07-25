import 'package:flutter/material.dart' hide Route;

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/routes/app/router_controller.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Router<AppRouterController>(
        builder: (context) => AppRouterController(context),
      ),
    );
  }
}
