import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:igflexin/routes/auth/widgets/text_form_field.dart';

import 'package:igflexin/utils/keyboard_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
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
  final _passKey = GlobalKey<FormFieldState>();

  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmationFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Form(
      key: _formKey,
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
                    obscureText: false,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text!';
                      }
                    },
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
                    key: _passKey,
                    focusNode: _passwordFocusNode,
                    label: 'Password',
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text!';
                      }
                    },
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
                  focusNode: _confirmationFocusNode,
                  child: WhiteTextFormField(
                    focusNode: _confirmationFocusNode,
                    label: 'Confirmation',
                    obscureText: true,
                    validator: (value) {
                      //var password = _passKey.currentState.value;
                      if (value.isEmpty) {
                        return 'Please enter some text!';
                      } //else return equals(value, password) ? null : "Confirmation should match password";
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ResponsivityUtils.compute(50.0, context)),
            child: SignUpButton(
              controller: widget.controller,
              formKey: _formKey,
            ),
          ),
        ],
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
