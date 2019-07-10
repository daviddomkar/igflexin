import 'package:flutter/material.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';

class ApplePayButton extends StatelessWidget {
  ApplePayButton({Key key, @required this.controller})
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
        child: CurvedWhiteButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Buy with',
              ),
              Container(
                margin: EdgeInsets.only(left: ResponsivityUtils.compute(3.0, context)),
                child: Image.asset(
                  'assets/apple_pay.png',
                  height: ResponsivityUtils.compute(20.0, context),
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
          onPressed: () {
            // TODO launch Apple Pay
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
