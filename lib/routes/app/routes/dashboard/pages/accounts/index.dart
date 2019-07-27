import 'package:flutter/material.dart';
import 'package:igflexin/core/server.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class Accounts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: RaisedButton(
          highlightElevation: 0,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          color: Colors.black,
          child: Text(
            'Add test account',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: ResponsivityUtils.compute(16.0, context),
              color: Provider.of<SubscriptionRepository>(context)
                  .planTheme
                  .gradientStartColor,
            ),
          ),
          onPressed: () {
            Server.addAccount(
              username: 'testingigapp',
              password: 'Merkur33',
            );
          },
        ),
      ),
    );
  }
}
