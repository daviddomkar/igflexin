import 'package:flutter/material.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

const double _BOTTOM_HEIGHT_ = 80.0;

class SignOutButton extends StatelessWidget {
  SignOutButton({Key key, this.controller, this.systemBarsInfo})
      : height = Tween(begin: 0.0, end: _BOTTOM_HEIGHT_).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.5 / 2.25, curve: Curves.easeOutExpo),
        )),
        margin = Tween(
                begin: 0.0,
                end: systemBarsInfo.hasSoftwareNavigationBar
                    ? systemBarsInfo.navigationBarHeight
                    : systemBarsInfo.statusBarHeight)
            .animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.5 / 2.25, curve: Curves.easeOutExpo),
        )),
        scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.5 / 2.25 * 3, 1.000, curve: Curves.elasticOut),
        )),
        super(key: key);

  final AnimationController controller;
  final SystemBarsInfo systemBarsInfo;

  final Animation<double> height;
  final Animation<double> margin;
  final Animation<double> scale;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      height: ResponsivityUtils.compute(height.value, context),
      margin: EdgeInsets.only(bottom: margin.value),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.scale(
          scale: scale.value,
          child: Container(
            width: ResponsivityUtils.compute(300.0, context),
            height: ResponsivityUtils.compute(50.0, context),
            child: CurvedBlackBorderedTransparentButton(
              child: Text('Sign Out'),
              onPressed: () {
                Provider.of<AuthRepository>(context).signOut();
              },
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
