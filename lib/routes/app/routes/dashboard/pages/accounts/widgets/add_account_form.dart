import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/accounts.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/utils/validation_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class AddAccountForm extends StatefulWidget {
  AddAccountForm({
    this.username,
    this.password,
    this.onUsernameChange,
    this.onPasswordChange,
    this.onStateReceived,
    this.onErrorReceived,
  });

  final username;
  final password;
  final void Function(String) onUsernameChange;
  final void Function(String) onPasswordChange;
  final void Function(InstagramAccountState) onStateReceived;
  final void Function(String) onErrorReceived;

  @override
  _AddAccountFormState createState() {
    return _AddAccountFormState();
  }
}

class _AddAccountFormState extends State<AddAccountForm> {
  SubscriptionRepository _subscriptionRepository;
  InstagramRepository _instagramRepository;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _autoValidate = false;
  bool _addingAccount = false;

  String _username;
  String _password;

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _username = widget.username;
    _password = widget.password;

    _usernameController.text = _username;
    _passwordController.text = _password;

    _usernameController.addListener(() {
      setState(() {
        _username = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _usernameController.text);
        widget.onUsernameChange(_username);
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _password = ValidationUtils.trimLeadingAndTrailingWhitespace(
            _passwordController.text);
        widget.onPasswordChange(_password);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _instagramRepository = Provider.of<InstagramRepository>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addInstagramAccount() async {
    if (_formKey.currentState.validate()) {
      if (_addingAccount) return;

      setState(() {
        _addingAccount = true;
      });

      try {
        final response = await _instagramRepository.addInstagramAccount(
          username: _username,
          password: _password,
        );

        if (response.message == 'success') {
          widget.onStateReceived(InstagramAccountState.Running);
          Navigator.maybePop(context);
        } else if (response.message == 'checkpoint-required') {
          widget.onStateReceived(InstagramAccountState.CheckpointRequired);
        } else if (response.message == 'two-factor-required') {
          widget.onStateReceived(InstagramAccountState.TwoFactorAuthRequired);
        }
      } on CloudFunctionsException catch (e) {
        print(e);

        if (e.code == 'INVALID_ARGUMENT') {
          widget.onErrorReceived('Invalid username and password combination!');
        } else if (e.code == 'DEADLINE_EXCEEDED') {
          Navigator.maybePop(context);
        } else if (e.code == 'PERMISSION_DENIED') {
          widget.onErrorReceived('This user is already added to IGFlexin!');
        } else {
          widget.onErrorReceived('Unknown error occurred!');
        }
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsivityUtils.compute(20.0, context)),
      width: ResponsivityUtils.compute(320.0, context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsivityUtils.compute(20.0, context),
        ),
      ),
      child: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Instagram account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsivityUtils.compute(23.0, context),
                fontWeight: FontWeight.bold,
                color: Provider.of<SubscriptionRepository>(context)
                    .planTheme
                    .gradientStartColor,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: ResponsivityUtils.compute(10.0, context)),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(10.0, context),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  cursorColor: _usernameController.text.isEmpty && _autoValidate
                      ? Colors.red
                      : _subscriptionRepository.planTheme.gradientStartColor,
                  textSelectionColor:
                      _usernameController.text.isEmpty && _autoValidate
                          ? Colors.red.withOpacity(0.5)
                          : _subscriptionRepository.planTheme.gradientStartColor
                              .withOpacity(0.5),
                ),
                child: TextFormField(
                  focusNode: _usernameFocusNode,
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _usernameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  validator: _validateField,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'Username',
                    labelStyle: TextStyle(
                        color: _usernameFocusNode.hasFocus
                            ? _usernameController.text.isEmpty && _autoValidate
                                ? Colors.red
                                : _subscriptionRepository
                                    .planTheme.gradientStartColor
                            : null),
                    errorStyle: TextStyle(color: Colors.red),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: _subscriptionRepository
                            .planTheme.gradientStartColor,
                        width: ResponsivityUtils.compute(2.0, context),
                      ),
                    ),
                    focusColor:
                        _subscriptionRepository.planTheme.gradientStartColor,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  bottom: ResponsivityUtils.compute(20.0, context)),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsivityUtils.compute(10.0, context),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  cursorColor:
                      _subscriptionRepository.planTheme.gradientStartColor,
                  textSelectionColor: _subscriptionRepository
                      .planTheme.gradientStartColor
                      .withOpacity(0.5),
                ),
                child: TextFormField(
                  focusNode: _passwordFocusNode,
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _passwordFocusNode.unfocus();
                    _addInstagramAccount();
                  },
                  obscureText: true,
                  validator: _validateField,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(10.0, context),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: _passwordFocusNode.hasFocus
                            ? _subscriptionRepository
                                .planTheme.gradientStartColor
                            : null),
                    errorStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: _subscriptionRepository
                            .planTheme.gradientStartColor,
                        width: ResponsivityUtils.compute(2.0, context),
                      ),
                    ),
                    focusColor:
                        _subscriptionRepository.planTheme.gradientStartColor,
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
            GradientButton(
              width: ResponsivityUtils.compute(
                  _addingAccount ? 45.0 : 130.0, context),
              height: ResponsivityUtils.compute(45.0, context),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      opacity: !_addingAccount ? 1.0 : 0.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Add account',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      opacity: _addingAccount ? 1.0 : 0.0,
                      child: Container(
                        width: ResponsivityUtils.compute(30.0, context),
                        height: ResponsivityUtils.compute(30.0, context),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                _addInstagramAccount();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _validateField(String value) {
    value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);

    if (value.isEmpty) {
      return 'This field is required!';
    } else {
      return null;
    }
  }
}
