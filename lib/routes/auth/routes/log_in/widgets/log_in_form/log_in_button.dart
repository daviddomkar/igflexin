import 'package:flutter/material.dart';
import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/resources/auth_info.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/routes/auth/router_controller.dart';

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
  AnimationController _buttonScaleController;
  Animation<double> _scale;

  RouterController _routerController;

  @override
  void initState() {
    super.initState();
    _buttonScaleController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);

    _scale = Tween(begin: 50.0, end: 1.0).animate(CurvedAnimation(
      parent: _buttonScaleController,
      curve: new Interval(0.000, 1.000, curve: Curves.easeInOutExpo),
    ));

    _buttonScaleController.forward(from: 1.000);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routerController = Router.of<MainRouterController>(context);
    _routerController.registerAnimationController(_buttonScaleController);
  }

  @override
  void dispose() {
    _routerController.unregisterAnimationController(_buttonScaleController);
    _buttonScaleController.dispose();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    AuthInfoState state = Provider.of<AuthRepository>(context).info.state;

    return Transform.scale(
      scale: _scale.value,
      child: Transform.scale(
        scale: widget.scale.value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutExpo,
          width: ResponsivityUtils.compute(
              state == AuthInfoState.Pending ? 50.0 : 300, context),
          height: ResponsivityUtils.compute(50.0, context),
          margin:
              EdgeInsets.only(top: ResponsivityUtils.compute(10.0, context)),
          child: CurvedWhiteButton(
            padding: EdgeInsets.all(0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                    opacity: state == AuthInfoState.None ||
                            state == AuthInfoState.Error
                        ? 1.0
                        : 0.0,
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: ResponsivityUtils.compute(16.0, context),
                        color: Color.fromARGB(255, 223, 61, 139),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.ease,
                    opacity: state == AuthInfoState.Pending ? 1.0 : 0.0,
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: widget.onPressed,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _buttonScaleController,
      builder: _buildAnimation,
    );
  }
}
