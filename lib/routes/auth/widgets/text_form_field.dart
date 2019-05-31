import 'package:flutter/material.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

class WhiteTextFormField extends StatelessWidget {
  WhiteTextFormField({
    Key key,
    @required this.focusNode,
    this.label,
    this.validator,
    this.onSaved,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
  }) : super(key: key);

  final FocusNode focusNode;
  final String label;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsivityUtils.compute(15.0, context),
            vertical: ResponsivityUtils.compute(10.0, context)),
        labelText: label,
        alignLabelWithHint: true,
        errorMaxLines: 3,
        errorStyle: TextStyle(
          color: Colors.white,
        ),
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(200, 255, 255, 255)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white,
              width: ResponsivityUtils.compute(2.0, context)),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white,
              width: ResponsivityUtils.compute(2.0, context)),
        ),
      ),
    );
  }
}
