import 'package:flutter/material.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/keyboard_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

import 'buttons.dart';

class ErrorDialog extends StatefulWidget {
  ErrorDialog({Key key, this.title, this.message, this.onClose}) : super(key: key);

  final String title;
  final String message;
  final Function onClose;

  @override
  _ErrorDialogState createState() {
    return _ErrorDialogState();
  }
}

class _ErrorDialogState extends State<ErrorDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Animation<Color> _fadeInAnimation;
  Animation<double> _scaleContentInAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation =
        ColorTween(begin: Colors.transparent, end: Colors.black54)
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.000, 0.250, curve: Curves.easeOutExpo),
    ));

    _scaleContentInAnimation =
        Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.000, 1.000, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Material(
      color: _fadeInAnimation.value,
      child: SystemBarsInfoProvider(
        builder: (context, child, systemBarsInfo, orientation) {
          return KeyboardInfoProvider(
            builder: (context, keyboardInfo) {
              final bottomMargin = orientation == Orientation.landscape ||
                      (orientation == Orientation.portrait &&
                          keyboardInfo.offsetY >
                              systemBarsInfo.navigationBarHeight)
                  ? keyboardInfo.offsetY
                  : 0.0;

              return Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(
                  bottom: bottomMargin,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: IntrinsicHeight(
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight:
                              MediaQuery.of(context).size.height - bottomMargin,
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.maybePop(context);
                              },
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Transform.scale(
                                scale: _scaleContentInAnimation.value,
                                child: Container(
                                  key: ValueKey(2),
                                  padding: EdgeInsets.all(
                                    ResponsivityUtils.compute(20.0, context),
                                  ),
                                  width:
                                      ResponsivityUtils.compute(320.0, context),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      ResponsivityUtils.compute(20.0, context),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.title ?? 'Error',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: ResponsivityUtils.compute(
                                              23.0, context),
                                          fontWeight: FontWeight.bold,
                                          color: Provider.of<
                                                      SubscriptionRepository>(
                                                  context)
                                              .planTheme
                                              .gradientStartColor,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: ResponsivityUtils.compute(
                                                20.0, context)),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: ResponsivityUtils.compute(
                                              10.0, context),
                                        ),
                                        child: Text(
                                          widget.message,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      GradientButton(
                                        width: ResponsivityUtils.compute(
                                            130.0, context),
                                        height: ResponsivityUtils.compute(
                                            40.0, context),
                                        child: Text(
                                          'Ok',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (widget.onClose != null) {
                                              widget.onClose();
                                            }
                                            Navigator.maybePop(context);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _animationController.reverse();
        return true;
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: _buildAnimation,
      ),
    );
  }
}
