import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:igflexin/routes/auth/widgets/text_form_field.dart';

import 'package:igflexin/utils/keyboard_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

import 'log_in_button.dart';

class LogInForm extends StatefulWidget {
  LogInForm({Key key, this.controller})
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
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final _formKey = GlobalKey<FormState>();

  FocusNode _passwordFocusNode = FocusNode();
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
                  'LOG IN TO YOUR ACCOUNT',
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
          Container(
            margin: EdgeInsets.only(top: ResponsivityUtils.compute(50.0, context)),
            child: LogInButton(
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
