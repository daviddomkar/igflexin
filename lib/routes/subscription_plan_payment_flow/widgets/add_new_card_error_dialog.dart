import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/dialog.dart';
import 'package:provider/provider.dart';

class AddNewCardErrorDialog extends StatefulWidget {
  @override
  _AddNewCardErrorDialogState createState() {
    return _AddNewCardErrorDialogState();
  }
}

class _AddNewCardErrorDialogState extends State<AddNewCardErrorDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: new Interval(0.000, 1.000, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Transform.scale(
      scale: _scale.value,
      child: RoundedAlertDialog(
        title: Text(
          'Error',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsivityUtils.compute(23.0, context),
            fontWeight: FontWeight.bold,
            color: Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientStartColor,
          ),
        ),
        content: Text(
          'An error occurred while adding a card. Check your card information!',
          textAlign: TextAlign.center,
        ),
        actions: [
          GradientButton(
            width: ResponsivityUtils.compute(80.0, context),
            height: ResponsivityUtils.compute(45.0, context),
            child: Text(
              'OK',
              style: TextStyle(
                  fontSize: ResponsivityUtils.compute(15.0, context),
                  color: Colors.white),
            ),
            onPressed: () {
              _animationController.reverse().then((_) {
                Navigator.of(context).pop();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _animationController.reverse();
        return true;
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: _buildAnimation,
      ),
    );
  }
}
