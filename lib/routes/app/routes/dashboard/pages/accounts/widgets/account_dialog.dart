import 'package:flutter/material.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/add_account_form.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/confirm_delete.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/edit_account_form.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/edit_or_delete.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/error_message.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/security_code_form.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/widgets/two_factor_auth_form.dart';
import 'package:igflexin/utils/keyboard_utils.dart';

class AccountDialog extends StatefulWidget {
  const AccountDialog({Key key, this.account, this.edit = false})
      : super(key: key);

  final InstagramAccount account;
  final bool edit;

  @override
  _AccountDialogState createState() {
    return _AccountDialogState();
  }
}

class _AccountDialogState extends State<AccountDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Animation<Color> _fadeInAnimation;
  Animation<double> _scaleContentInAnimation;

  String _username = '';
  String _password = '';
  String _editUsername = '';
  String _editPassword = '';
  String _securityCode = '';
  String _twoFactorAuthCode = '';

  String _error = '';
  InstagramAccountState _state;
  EditOrDeleteActionType _editAction;

  @override
  void initState() {
    super.initState();

    if (widget.edit) {
      _editAction = EditOrDeleteActionType.None;
    }

    if (widget.account != null) {
      _state = getInstagramAccountStateFromString(widget.account.status);
      _username = widget.account.username;
    } else {
      _state = InstagramAccountState.None;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation =
        ColorTween(begin: Colors.transparent, end: Colors.black54)
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.000, 0.250, curve: Curves.easeOutExpo),
    ));

    _scaleContentInAnimation =
        Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.000, 1.000, curve: Curves.elasticOut),
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
    if (_editAction != null) {
      if (_editAction == EditOrDeleteActionType.None) {
        return EditOrDelete(
          account: widget.account,
          onEditOrDeleteActionChange: (value) =>
              setState(() => _editAction = value),
        );
      } else if (_editAction == EditOrDeleteActionType.Edit) {
        return EditAccountForm(
          id: widget.account.id,
          username: _editUsername,
          password: _editPassword,
          onUsernameChange: (value) => setState(() => _editUsername = value),
          onPasswordChange: (value) => setState(() => _editPassword = value),
          onStateReceived: (value) => setState(() => _state = value),
          onErrorReceived: (value) => setState(() => _error = value),
        );
      } else {
        return ConfirmDelete(
          account: widget.account,
        );
      }
    } else if (_error.isNotEmpty) {
      return ErrorMessage(
        message: _error,
        onErrorDismissed: () => setState(() => _error = ''),
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
    } else if (_state == InstagramAccountState.CheckpointRequired) {
      return SecurityCodeForm(
        username: _username,
        securityCode: _securityCode,
        onSecurityCodeChange: (value) => setState(() => _securityCode = value),
        onStateReceived: (value) => setState(() => _state = value),
        onErrorReceived: (value) => setState(() => _error = value),
      );
    } else if (_state == InstagramAccountState.TwoFactorAuthRequired) {
      return TwoFactorAuthForm(
        username: _username,
        securityCode: _twoFactorAuthCode,
        onSecurityCodeChange: (value) =>
            setState(() => _twoFactorAuthCode = value),
        onStateReceived: (value) => setState(() => _state = value),
        onErrorReceived: (value) => setState(() => _error = value),
      );
    } else if (_state == InstagramAccountState.InvalidUser ||
        _state == InstagramAccountState.BadPassword) {
      return EditAccountForm(
        id: widget.account.id,
        username: _editUsername,
        password: _editPassword,
        onUsernameChange: (value) => setState(() => _editUsername = value),
        onPasswordChange: (value) => setState(() => _editPassword = value),
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
                            child: Transform.scale(
                              scale: _scaleContentInAnimation.value,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 2000),
                                transitionBuilder: (child, animation) {
                                  final tween =
                                      Tween(begin: 0.0, end: 1.0).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Interval(
                                        0.500,
                                        1.000,
                                        curve: Curves.elasticOut,
                                      ),
                                    ),
                                  );

                                  return ScaleTransition(
                                    child: child,
                                    scale: tween,
                                  );
                                },
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
        if (_editAction != null &&
            (_editAction != EditOrDeleteActionType.None)) {
          setState(() {
            _editAction = EditOrDeleteActionType.None;
          });
          return false;
        } else {
          await _animationController.reverse();
          return true;
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: _buildAnimation,
      ),
    );
  }
}
