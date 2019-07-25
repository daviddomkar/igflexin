import 'package:flutter/material.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/card_selection_dialog.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';

class CreditOrDebitCardButton extends StatefulWidget {
  CreditOrDebitCardButton({Key key, @required this.controller})
      : scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.400, 0.900, curve: Curves.elasticOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> scale;

  @override
  _CreditOrDebitCardButtonState createState() => _CreditOrDebitCardButtonState();
}

class _CreditOrDebitCardButtonState extends State<CreditOrDebitCardButton> {
  Widget _buildAnimation(BuildContext context, Widget child) {
    return Transform.scale(
      scale: widget.scale.value,
      child: Container(
        width: ResponsivityUtils.compute(300.0, context),
        height: ResponsivityUtils.compute(50.0, context),
        child: CurvedWhiteBorderedTransparentButton(
          child: Text(
            'Buy with Credit or Debit card',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            showGeneralDialog(
              context: context,
              pageBuilder: (BuildContext buildContext, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return CardSelectionDialog(
                  routerController: Router.of<MainRouterController>(context),
                );
              },
              barrierDismissible: true,
              barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
              barrierColor: Colors.black54,
              transitionDuration: const Duration(milliseconds: 150),
              transitionBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation, Widget child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: child,
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: _buildAnimation,
    );
  }
}
