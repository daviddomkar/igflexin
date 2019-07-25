import 'package:flutter/material.dart';
import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: RaisedButton(
          highlightElevation: 0,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          color: Colors.black,
          child: Text(
            'Sign out',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: ResponsivityUtils.compute(16.0, context),
              color: Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
            ),
          ),
          onPressed: () {
            Provider.of<AuthRepository>(context).signOut();
          },
        ),
      ),
    );
  }
}
