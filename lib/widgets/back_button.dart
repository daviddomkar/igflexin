import 'package:flutter/material.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

class BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: ResponsivityUtils.compute(30.0, context),
          left: ResponsivityUtils.compute(10.0, context),
        ),
        child: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back_ios,
            size: ResponsivityUtils.compute(36.0, context),
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
    );
  }
}
