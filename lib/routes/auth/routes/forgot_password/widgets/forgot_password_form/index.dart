import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/auth_info.dart';
import 'package:igflexin/routes/auth/routes/forgot_password/widgets/forgot_password_form/send_email_for_password_change_button.dart';

import 'package:igflexin/routes/auth/widgets/text_form_field.dart';

import 'package:igflexin/utils/keyboard_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/utils/validation_utils.dart';
import 'package:igflexin/widgets/dialog.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/error_dialog.dart';

import 'package:provider/provider.dart';

class ForgotPasswordForm extends StatefulWidget {
  ForgotPasswordForm({Key key, this.controller})
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
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _processing = false;

  bool _autoValidate = false;
  String _email;

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
                  'FORGOT YOUR PASSWORD?',
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
                    label: 'Your IGFlexin Email',
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
          Container(
            margin: EdgeInsets.only(top: ResponsivityUtils.compute(30.0, context)),
            child: Transform.scale(
              scale: 1.0,
              child: SendEmailForPasswordChangeButton(
                processing: _processing,
                controller: widget.controller,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    try {
                      if (_processing) return;

                      setState(() {
                        _processing = true;
                      });
                      await Provider.of<AuthRepository>(context).sendPasswordResetEmail(email: _email);
                      Navigator.maybePop(context);
                    } catch (e) {
                      setState(() {
                        _processing = false;
                      });
                      showModalWidget(context, ErrorDialog(
                        title: 'Error',
                        message: 'Could not send password reset email at the moment. Try again later!',
                      ));
                    }
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
    super.dispose();
  }
}
