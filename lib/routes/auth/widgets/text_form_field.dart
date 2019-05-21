import 'package:flutter/material.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

class WhiteTextFormField extends StatelessWidget {
  WhiteTextFormField({Key key, @required this.focusNode, this.label, this.validator, this.obscureText})
      : super(key: key);

  final FocusNode focusNode;
  final String label;
  final FormFieldValidator<String> validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      validator: validator,
      obscureText: obscureText,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsivityUtils.compute(15.0, context), vertical: ResponsivityUtils.compute(10.0, context)),
        labelText: label,
        alignLabelWithHint: true,
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
          borderSide: BorderSide(color: Colors.white, width: ResponsivityUtils.compute(2.0, context)),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: ResponsivityUtils.compute(2.0, context)),
        ),
      ),
    );
  }
}
