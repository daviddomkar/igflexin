import 'package:flutter/material.dart';

import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/icons/auth_provider_icons.dart';

class AuthProviderIconsBar extends StatelessWidget {
  AuthProviderIconsBar({Key key, this.controller})
      : scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.500, 1.000, curve: Curves.elasticOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> scale;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      width: ResponsivityUtils.compute(250.0, context),
      height: ResponsivityUtils.compute(80.0, context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: scale.value,
            child: Icon(
              AuthProviderIcons.google,
              color: Colors.white,
              size: ResponsivityUtils.compute(40.0, context),
            ),
          ),
          Transform.scale(
            scale: scale.value,
            child: Icon(
              AuthProviderIcons.instagram,
              color: Colors.white,
              size: ResponsivityUtils.compute(40.0, context),
            ),
          ),
          Transform.scale(
            scale: scale.value,
            child: Icon(
              AuthProviderIcons.facebook,
              color: Colors.white,
              size: ResponsivityUtils.compute(40.0, context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: _buildAnimation,
    );
  }
}
