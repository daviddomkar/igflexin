import 'package:flutter/material.dart' hide Route;

import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/system_bars_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/router_controller.dart';

import 'package:provider/provider.dart';

void main() => runApp(IGFlexinApp());

class IGFlexinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SystemBarsRepository>(
          builder: (_) => SystemBarsRepository(),
        ),
        Provider<RouterRepository>(
          builder: (_) => RouterRepository(),
        ),
        ChangeNotifierProvider<AuthRepository>(
          builder: (_) => AuthRepository(),
        ),
        ChangeNotifierProvider<UserRepository>(
          builder: (_) => UserRepository(),
        ),
      ],
      child: SystemBarsObserver(
        child: MaterialApp(
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: IGFlexinScrollBehavior(),
              child: child,
            );
          },
          theme: ThemeData(
            fontFamily: 'LatoLatin',
            primaryColor: Color.fromARGB(255, 223, 61, 139),
            accentColor: Color.fromARGB(255, 255, 161, 94),
          ),
          home: RouterPopScope(
            child: Router<MainRouterController>(
              builder: (context) => MainRouterController(context),
            ),
          ),
        ),
      ),
    );
  }
}

class IGFlexinScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
