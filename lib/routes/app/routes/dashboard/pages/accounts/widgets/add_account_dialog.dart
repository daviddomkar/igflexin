import 'package:flutter/material.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/utils/keyboard_utils.dart';

class AddAccountDialog extends StatefulWidget {
  @override
  _AddAccountDialogState createState() {
    return _AddAccountDialogState();
  }
}

class _AddAccountDialogState extends State<AddAccountDialog>
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
      curve: new Interval(0.000, 0.250, curve: Curves.easeOutExpo),
    ));

    _scaleContentInAnimation =
        Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: new Interval(0.000, 1.000, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height - bottomMargin,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.maybePop(context);
                            },
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: AnimatedSwitcher(
                              switchInCurve: Curves.elasticOut,
                              duration: const Duration(milliseconds: 1000),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                child: child,
                                scale: animation,
                              ),
                              child: Transform.scale(
                                scale: _scaleContentInAnimation.value,
                                child: Container(
                                  key: ValueKey(0),
                                  width: 200.0,
                                  height: 200.0,
                                  color: Colors.red,
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
      }),
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
