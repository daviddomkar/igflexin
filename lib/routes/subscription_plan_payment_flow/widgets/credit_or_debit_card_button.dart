import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/routes/subscription_plan_payment_flow/widgets/card_selection_dialog.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class CreditOrDebitCardButton extends StatelessWidget {
  CreditOrDebitCardButton({Key key, @required this.controller})
      : scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.400, 0.900, curve: Curves.elasticOut),
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
        child: CurvedWhiteBorderedTransparentButton(
          child: Text(
            'Buy with Credit or Debit card',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext dialogContext) {
                return CardSelectionDialog();
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
      animation: controller,
      builder: _buildAnimation,
    );
  }
}
