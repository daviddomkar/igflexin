import 'package:flutter/material.dart';

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/routes/auth/router_controller.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class LogInButton extends StatelessWidget {
  LogInButton({Key key, this.controller})
      : scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.500, 1.000, curve: Curves.elasticOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> scale;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Transform.scale(
      scale: scale.value,
      child: Container(
        width: ResponsivityUtils.compute(300.0, context),
        height: ResponsivityUtils.compute(50.0, context),
        margin: EdgeInsets.only(top: ResponsivityUtils.compute(10.0, context)),
        child: CurvedWhiteButton(
          child: Text(
            'I have an account already',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: ResponsivityUtils.compute(16.0, context),
              color: Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
            ),
          ),
          onPressed: () {
            Router.of<AuthRouterController>(context).push('login');
          },
        ),
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
