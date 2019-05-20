import 'package:flutter/material.dart';

import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/icons/auth_provider_icons.dart';

class AuthProviderIconsBar extends StatelessWidget {
  AuthProviderIconsBar({Key key, this.controller}) : super(key: key);

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsivityUtils.compute(250.0, context),
      height: ResponsivityUtils.compute(80.0, context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AuthProviderIcons.google,
            color: Colors.white,
            size: ResponsivityUtils.compute(40.0, context),
          ),
          Icon(
            AuthProviderIcons.instagram,
            color: Colors.white,
            size: ResponsivityUtils.compute(40.0, context),
          ),
          Icon(
            AuthProviderIcons.facebook,
            color: Colors.white,
            size: ResponsivityUtils.compute(40.0, context),
          ),
        ],
      ),
    );
  }
}
