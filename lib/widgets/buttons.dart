import 'package:flutter/material.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

class CurvedWhiteBorderedTransparentButton extends StatelessWidget {
  CurvedWhiteBorderedTransparentButton({@required this.onPressed, @required this.child});

  final GestureTapCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
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
  CurvedWhiteButton({@required this.onPressed, @required this.child, this.padding});

  final GestureTapCallback onPressed;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (padding == null) {
      return FlatButton(
        color: Colors.white,
        child: child,
        onPressed: onPressed,
        shape: const StadiumBorder(),
      );
    } else {
      return FlatButton(
        padding: padding,
        color: Colors.white,
        child: child,
        onPressed: onPressed,
        shape: const StadiumBorder(),
      );
    }
  }
}

class GradientButton extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Function onPressed;
  final borderRadius = BorderRadius.circular(128.0);

  GradientButton({
    Key key,
    @required this.child,
    this.width = 200.0,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor,
                    ],
                    begin: FractionalOffset.centerLeft,
                    end: FractionalOffset.centerRight,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: width,
            height: height,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              padding: EdgeInsets.zero,
              child: Center(child: child),
              onPressed: onPressed,
              color: Colors.transparent,
            ),
          ),
        ],
      );
}
