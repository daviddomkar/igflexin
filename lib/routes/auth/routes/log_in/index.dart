import 'package:flutter/material.dart' hide Title;

import 'package:igflexin/utils/router_utils.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

import 'package:flutter_system_bars/flutter_system_bars.dart';

import 'widgets/log_in_form/index.dart';
import 'widgets/auth_provider_icons_bar.dart';
import 'widgets/problems_with_logging_in.dart';

const double _BOTTOM_HEIGHT_ = 104.0;

class LogIn extends StatelessWidget {
  Widget build(BuildContext context) {
    return RouterAnimationController(
      routerName: 'auth',
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return SystemBarsInfoProvider(builder: (context, child, systemBarsInfo, orientation) {
          return _LogIn(controller, systemBarsInfo, orientation);
        });
      },
    );
  }
}

class _LogIn extends StatelessWidget {
  _LogIn(this.controller, this.systemBarsInfo, this.orientation);

  final AnimationController controller;
  final SystemBarsInfo systemBarsInfo;
  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: KeyboardInfoProvider(
            builder: (context, info) {
              return Container(
                decoration: BoxDecoration(color: Colors.blue),
                constraints: orientation == Orientation.landscape
                    ? BoxConstraints.expand(
                        height: ResponsivityUtils.compute(360, context),
                      )
                    : BoxConstraints(),
                margin: EdgeInsets.only(
                    top: ((orientation == Orientation.portrait && info.offsetY <= systemBarsInfo.navigationBarHeight
                        ? systemBarsInfo.navigationBarHeight + ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context)
                        : 0.0)),
                    bottom: info.offsetY - ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context) > 0
                        ? info.offsetY -
                            (ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context) +
                                (orientation == Orientation.portrait ? systemBarsInfo.navigationBarHeight : 0.0))
                        : 0.0),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ResponsivityUtils.compute(40.0, context)),
                    child: LogInForm(),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          height: ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context),
          margin:
              EdgeInsets.only(bottom: orientation == Orientation.portrait ? systemBarsInfo.navigationBarHeight : 0.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AuthProviderIconsBar(controller: controller),
                ProblemsWithLoggingIn(controller: controller),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

typedef Widget KeyboardInfoProviderBuilder(
  BuildContext context,
  KeyboardInfo info,
);

class KeyboardInfo {
  KeyboardInfo(this.offsetY);

  final double offsetY;
}

class KeyboardInfoProvider extends StatefulWidget {
  KeyboardInfoProvider({this.builder});

  final KeyboardInfoProviderBuilder builder;

  @override
  _KeyboardInfoProviderState createState() => _KeyboardInfoProviderState();
}

class _KeyboardInfoProviderState extends State<KeyboardInfoProvider> with WidgetsBindingObserver {
  double offsetY = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    _updateInfo();
  }

  Future<Null> _keyboardToggled() async {
    if (mounted) {
      EdgeInsets edgeInsets = MediaQuery.of(context).viewInsets;
      while (mounted && MediaQuery.of(context).viewInsets == edgeInsets) {
        await new Future.delayed(const Duration(milliseconds: 10));
      }
    }

    return;
  }

  Future<Null> _updateInfo() async {
    await Future.any([new Future.delayed(const Duration(milliseconds: 300)), _keyboardToggled()]);

    final mediaQuery = MediaQuery.of(context);
    final screenInsets = mediaQuery.viewInsets;

    offsetY = screenInsets.bottom;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, KeyboardInfo(offsetY));
  }
}
