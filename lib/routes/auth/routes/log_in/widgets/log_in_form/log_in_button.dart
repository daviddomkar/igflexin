import 'package:flutter/material.dart';
import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/resources/auth_info.dart';

import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class LogInButton extends StatefulWidget {
  LogInButton({
    Key key,
    this.controller,
    this.onPressed,
  })  : scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.400, 0.900, curve: Curves.elasticOut),
        )),
        super(key: key);

  final AnimationController controller;
  final GestureTapCallback onPressed;

  final Animation<double> scale;

  @override
  _LogInButtonState createState() => _LogInButtonState();
}

class _LogInButtonState extends State<LogInButton>
    with SingleTickerProviderStateMixin {
  AnimationController _buttonShrinkController;
  Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _buttonShrinkController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);

    _width = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _buttonShrinkController,
      curve: new Interval(0.400, 0.900, curve: Curves.elasticOut),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.scale.value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: ResponsivityUtils.compute(
            Provider.of<AuthRepository>(context).info.state ==
                    AuthInfoState.Pending
                ? 50.0
                : 300,
            context),
        height: ResponsivityUtils.compute(50.0, context),
        margin: EdgeInsets.only(top: ResponsivityUtils.compute(10.0, context)),
        child: CurvedWhiteButton(
          child: Text(
            'Log In',
            style: TextStyle(
              fontSize: ResponsivityUtils.compute(16.0, context),
              color: Color.fromARGB(255, 223, 61, 139),
            ),
          ),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
