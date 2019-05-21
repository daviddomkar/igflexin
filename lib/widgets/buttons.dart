import 'package:flutter/material.dart';

class CurvedWhiteBorderedTransparentButton extends StatelessWidget {
  CurvedWhiteBorderedTransparentButton(
      {@required this.onPressed, @required this.child});

  final GestureTapCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      highlightElevation: 0,
      elevation: 0,
      color: Colors.transparent,
      child: child,
      onPressed: onPressed,
      shape: const StadiumBorder(
        side: const BorderSide(
          color: Colors.white,
        ),
      ),
    );
  }
}

class CurvedWhiteButton extends StatelessWidget {
  CurvedWhiteButton({@required this.onPressed, @required this.child});

  final GestureTapCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      highlightElevation: 0,
      elevation: 0,
      color: Colors.white,
      child: child,
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}
