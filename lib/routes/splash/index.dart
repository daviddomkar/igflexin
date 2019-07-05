import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:provider/provider.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          colors: [
            Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
            Provider.of<SubscriptionRepository>(context).planTheme.gradientEndColor,
          ],
        ),
      ),
    );
  }
}
