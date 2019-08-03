import 'package:flutter/material.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

class ErrorMessage extends StatelessWidget {
  ErrorMessage({@required this.message});

  final String message;

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
      child: Text(message),
    );
  }
}
