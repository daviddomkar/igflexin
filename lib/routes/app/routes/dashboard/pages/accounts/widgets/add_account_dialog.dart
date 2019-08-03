import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/add_account_form.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/error_message.dart';
import 'package:igflexin/utils/keyboard_utils.dart';

class AddAccountDialog extends StatefulWidget {
  @override
  _AddAccountDialogState createState() {
    return _AddAccountDialogState();
  }
}

class _AddAccountDialogState extends State<AddAccountDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Animation<Color> _fadeInAnimation;
  Animation<double> _scaleContentInAnimation;

  String _username = '';
  String _password = '';

  String _error = '';
  InstagramAccountState _state = InstagramAccountState.None;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation =
        ColorTween(begin: Colors.transparent, end: Colors.black54)
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: new Interval(0.000, 0.250, curve: Curves.easeOutExpo),
    ));

    _scaleContentInAnimation =
        Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: new Interval(0.000, 1.000, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildChild(BuildContext context) {
    if (_error.isNotEmpty) {
      return ErrorMessage(
        message: _error,
      );
    } else if (_state == InstagramAccountState.None) {
      return AddAccountForm(
        username: _username,
        password: _password,
        onUsernameChange: (value) => setState(() => _username = value),
        onPasswordChange: (value) => setState(() => _password = value),
        onStateReceived: (value) => setState(() => _state = value),
        onErrorReceived: (value) => setState(() => _error = value),
      );
    } else {
      return Text(
        _state.toString(),
        style: TextStyle(
          color: Colors.white,
        ),
      );
    }
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Material(
      color: _fadeInAnimation.value,
      child: SystemBarsInfoProvider(
          builder: (context, child, systemBarsInfo, orientation) {
        return KeyboardInfoProvider(
          builder: (context, keyboardInfo) {
            final bottomMargin = orientation == Orientation.landscape ||
                    (orientation == Orientation.portrait &&
                        keyboardInfo.offsetY >
                            systemBarsInfo.navigationBarHeight)
                ? keyboardInfo.offsetY
                : 0.0;

            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                bottom: bottomMargin,
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height - bottomMargin,
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.maybePop(context);
                            },
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: AnimatedSwitcher(
                              switchInCurve: Curves.elasticOut,
                              duration: const Duration(milliseconds: 1000),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                child: child,
                                scale: animation,
                              ),
                              child: Transform.scale(
                                scale: _scaleContentInAnimation.value,
                                child: _buildChild(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
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
