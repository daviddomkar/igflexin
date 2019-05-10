import 'package:flutter/material.dart';
import 'package:igflexin/utils/keyboard_utils.dart';

import 'package:igflexin/utils/responsivity_utils.dart';

import 'log_in_button.dart';

class LogInForm extends StatefulWidget {
  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final _formKey = GlobalKey<FormState>();

  FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: ResponsivityUtils.compute(10.0, context)),
            child: TextFormField(
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsivityUtils.compute(15.0, context),
                    vertical: ResponsivityUtils.compute(10.0, context)),
                labelText: 'Email',
                alignLabelWithHint: true,
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(200, 255, 255, 255)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: ResponsivityUtils.compute(2.0, context)),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ResponsivityUtils.compute(10.0, context)),
            child: EnsureVisibleWhenFocused(
              focusNode: _passwordFocusNode,
              child: TextFormField(
                focusNode: _passwordFocusNode,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsivityUtils.compute(15.0, context),
                      vertical: ResponsivityUtils.compute(10.0, context)),
                  labelText: 'Password',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(200, 255, 255, 255)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: ResponsivityUtils.compute(2.0, context)),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: ResponsivityUtils.compute(50.0, context)),
            child: LogInButton(),
          ),
        ],
      ),
    );
  }
}
