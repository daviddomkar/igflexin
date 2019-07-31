import 'package:flutter/material.dart' hide Route;

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';

import 'package:igflexin/routes/auth/router_controller.dart';
import 'package:provider/provider.dart';

class Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: true,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            colors: [
              Provider.of<SubscriptionRepository>(context)
                  .planTheme
                  .gradientStartColor,
              Provider.of<SubscriptionRepository>(context)
                  .planTheme
                  .gradientEndColor
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
                child: IntrinsicHeight(
                  child: Router<AuthRouterController>(
                    builder: (context) => AuthRouterController(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
