import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart' hide Route;

import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/instagram_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/repositories/system_bars_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/router_controller.dart';

import 'package:provider/provider.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  runApp(IGFlexinApp());
}

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
        ChangeNotifierProvider<SubscriptionRepository>(
          builder: (_) => SubscriptionRepository(),
        ),
        ChangeNotifierProvider<InstagramRepository>(
          builder: (_) => InstagramRepository(),
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
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
