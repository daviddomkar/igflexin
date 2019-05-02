import 'package:flutter/material.dart';

import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';

class LogInButton extends StatelessWidget {
  /*LogInButton({Key key, this.controller})
      : scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.500, 1.000, curve: Curves.elasticOut),
        )),
        super(key: key);*/

  //final AnimationController controller;

  //final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return /*Transform.scale(
      scale: scale.value,
      child:*/
        Container(
      width: ResponsivityUtils.compute(300.0, context),
      height: ResponsivityUtils.compute(50.0, context),
      margin: EdgeInsets.only(top: ResponsivityUtils.compute(10.0, context)),
      child: CurvedWhiteButton(
        child: Text(
          'Log In',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: ResponsivityUtils.compute(16.0, context),
            color: Color.fromARGB(255, 223, 61, 139),
          ),
        ),
        onPressed: () {
          // TODO Log In
        },
      ),
      /*),*/
    );
  }
}
