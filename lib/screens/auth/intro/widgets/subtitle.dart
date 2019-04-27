import 'package:flutter/material.dart';

import 'package:igflexin/utils/responsivity_utils.dart';

class Subtitle extends StatelessWidget {
  Subtitle({Key key, this.controller})
      : opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        offsetY = Tween(begin: 15.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> opacity;
  final Animation<double> offsetY;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Transform.translate(
      offset: Offset(0.0, offsetY.value),
      child: Opacity(
        opacity: opacity.value,
        child: Text(
          'Log In and take your Instagram business to the next level.',
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsivityUtils.compute(22.0, context),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
