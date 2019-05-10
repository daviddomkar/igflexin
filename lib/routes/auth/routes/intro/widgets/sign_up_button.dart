import 'package:flutter/material.dart';

import 'package:igflexin/utils/router_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';

class SignUpButton extends StatelessWidget {
  SignUpButton({Key key, this.controller})
      : scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.400, 0.900, curve: Curves.elasticOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale.value,
      origin: Offset(0.0, ResponsivityUtils.compute(25.0, context)),
      child: Container(
        width: ResponsivityUtils.compute(300.0, context),
        height: ResponsivityUtils.compute(50.0, context),
        margin: EdgeInsets.only(top: ResponsivityUtils.compute(70.0, context)),
        child: CurvedWhiteBorderedTransparentButton(
          child: Text(
            "I am new to this app",
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: ResponsivityUtils.compute(16.0, context),
              color: Colors.white,
            ),
          ),
          onPressed: () {
            RouterController.of(context, 'main').switchRoute('main', 'app');
          },
        ),
      ),
    );
  }
}
