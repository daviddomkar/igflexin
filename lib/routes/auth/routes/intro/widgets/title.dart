import 'package:flutter/material.dart';

import 'package:igflexin/utils/responsivity_utils.dart';

class Title extends StatelessWidget {
  Title({Key key, this.controller})
      : opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOut),
        )),
        offsetY = Tween(begin: 15.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOut),
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
          'Hello.',
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsivityUtils.compute(52.0, context),
            fontWeight: FontWeight.w900,
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
