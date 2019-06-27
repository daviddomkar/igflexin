import 'package:flutter/material.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

const double _TOP_HEIGHT_ = 80.0;

class Title extends StatelessWidget {
  Title({Key key, this.controller, this.systemBarsInfo})
      : height = Tween(begin: 0.0, end: _TOP_HEIGHT_).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOutExpo),
        )),
        margin = Tween(
                begin: 0.0,
                end: systemBarsInfo.hasSoftwareNavigationBar
                    ? systemBarsInfo.navigationBarHeight
                    : systemBarsInfo.statusBarHeight)
            .animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOutExpo),
        )),
        opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        offsetY = Tween(begin: 10.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        super(key: key);

  final AnimationController controller;
  final SystemBarsInfo systemBarsInfo;

  final Animation<double> height;
  final Animation<double> margin;
  final Animation<double> opacity;
  final Animation<double> offsetY;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      height: ResponsivityUtils.compute(height.value, context),
      margin: EdgeInsets.only(top: margin.value),
      child: Align(
        alignment: Alignment.topCenter,
        child: Transform.translate(
          offset: Offset(0.0, offsetY.value),
          child: Opacity(
            opacity: opacity.value,
            child: Text(
              'Choose a plan.',
              style: TextStyle(
                fontSize: ResponsivityUtils.compute(40.0, context),
                fontWeight: FontWeight.w900,
              ),
            ),
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
