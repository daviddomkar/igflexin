import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:provider/provider.dart';

class Overview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientStartColor,
          ),
        ),
      ),
    );
  }
}
