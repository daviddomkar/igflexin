import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/auth_info.dart';

import 'package:igflexin/routes/auth/widgets/text_form_field.dart';

import 'package:igflexin/utils/keyboard_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/utils/validation_utils.dart';
import 'package:igflexin/widgets/dialog.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/error_dialog.dart';

import 'package:provider/provider.dart';

import 'sign_up_button.dart';

class SignUpForm extends StatefulWidget {
  SignUpForm({Key key, this.controller})
      : opacityTitle = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOut),
        )),
        offsetYTitle = Tween(begin: 15.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOut),
        )),
        opacityTextFields = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        offsetYTextFields = Tween(begin: 15.0, end: 0.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.250, 0.500, curve: Curves.easeOut),
        )),
        super(key: key);

  final AnimationController controller;

  final Animation<double> opacityTitle;
  final Animation<double> offsetYTitle;
  final Animation<double> opacityTextFields;
  final Animation<double> offsetYTextFields;

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmationFocusNode = FocusNode();

  bool _errorDialogVisible = false;
  bool _autoValidate = false;
  String _email;
  String _password;
  String _passwordConfirmation;

  AuthRepository _authRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _authRepository = Provider.of<AuthRepository>(context);
    _authRepository.addListener(_authInfoListener);
  }

  void _authInfoListener() {
    if (_authRepository.info.state == AuthInfoState.Error) {
      if (!_errorDialogVisible) {
        _errorDialogVisible = true;
        showModalWidget(context, ErrorDialog(
          title: 'SignUp error',
          message: AuthRepository.getAuthErrorMessage(_authRepository.info.data),
          onClose: () {
            _errorDialogVisible = false;
          },
        ));
      }
    }
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0.0, widget.offsetYTitle.value),
            child: Opacity(
              opacity: widget.opacityTitle.value,
              child: Container(
                margin: EdgeInsets.only(bottom: ResponsivityUtils.compute(30.0, context)),
                child: Text(
                  'CREATE YOUR ACCOUNT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: ResponsivityUtils.compute(23.0, context),
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0.0, widget.offsetYTextFields.value),
            child: Opacity(
              opacity: widget.opacityTextFields.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ResponsivityUtils.compute(10.0, context)),
                child: EnsureVisibleWhenFocused(
                  focusNode: _emailFocusNode,
                  child: WhiteTextFormField(
                    focusNode: _emailFocusNode,
                    label: 'Email',
                    onSaved: (value) {
                      value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);
                      _email = value;
                    },
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0.0, widget.offsetYTextFields.value),
            child: Opacity(
              opacity: widget.opacityTextFields.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ResponsivityUtils.compute(10.0, context)),
                child: EnsureVisibleWhenFocused(
                  focusNode: _passwordFocusNode,
                  child: WhiteTextFormField(
                    focusNode: _passwordFocusNode,
                    label: 'Password',
                    onSaved: (value) {
                      value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);
                      _password = value;
                    },
                    validator: _validatePassword,
                    obscureText: true,
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0.0, widget.offsetYTextFields.value),
            child: Opacity(
              opacity: widget.opacityTextFields.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: ResponsivityUtils.compute(10.0, context)),
                child: EnsureVisibleWhenFocused(
                  focusNode: _passwordConfirmationFocusNode,
                  child: WhiteTextFormField(
                    focusNode: _passwordConfirmationFocusNode,
                    label: 'Password confirmation',
                    onSaved: (value) {
                      value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);
                      _passwordConfirmation = value;
                    },
                    validator: _validatePasswordConfirmation,
                    obscureText: true,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ResponsivityUtils.compute(50.0, context)),
            child: Transform.scale(
              scale: 1.0,
              child: SignUpButton(
                controller: widget.controller,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    Provider.of<AuthRepository>(context)
                        .signUpWithEmailAndPassword(_email, _password);
                  } else {
                    setState(
                      () {
                        _autoValidate = true;
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);

    value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);

    if (value.isEmpty) {
      return 'This field is required!';
    } else if (!regex.hasMatch(value)) {
      return 'Enter valid email!';
    } else {
      return null;
    }
  }

  String _validatePassword(String value) {
    Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
    RegExp regex = new RegExp(pattern);

    value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);

    if (value.isEmpty) {
      return 'This field is required!';
    } else if (!regex.hasMatch(value)) {
      return 'Password has to have minimum of eight characters, at least one uppercase letter, one lowercase letter and one number!';
    } else {
      return null;
    }
  }

  String _validatePasswordConfirmation(String value) {
    value = ValidationUtils.trimLeadingAndTrailingWhitespace(value);

    _formKey.currentState.save();
    if (value.isEmpty) {
      return 'This field is required!';
    } else if (_password != _passwordConfirmation) {
      return 'Passwords doesn\'t match!';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: _buildAnimation,
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmationFocusNode.dispose();
    super.dispose();
  }
}
