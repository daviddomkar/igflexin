import 'package:flutter/material.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

class RoundedAlertDialog extends StatelessWidget {
  const RoundedAlertDialog({Key key, this.title, this.content, this.actions}) : super(key: key);

  final Widget title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.only(
        top: ResponsivityUtils.compute(15.0, context),
        left: ResponsivityUtils.compute(15.0, context),
        right: ResponsivityUtils.compute(15.0, context),
      ),
      contentPadding: EdgeInsets.only(
        top: ResponsivityUtils.compute(20.0, context),
        left: ResponsivityUtils.compute(15.0, context),
        right: ResponsivityUtils.compute(15.0, context),
        bottom: ResponsivityUtils.compute(10.0, context),
      ),
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(ResponsivityUtils.compute(25.0, context)))),
      title: Align(
        alignment: Alignment.center,
        child: title,
      ),
      content: Container(
        width: ResponsivityUtils.compute(200.0, context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: content,
            ),
            Padding(
              padding: EdgeInsets.only(top: ResponsivityUtils.compute(20.0, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
