import 'package:flutter/material.dart' hide Route;

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/system_bars_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';

import 'package:igflexin/resources/user.dart';

import 'package:igflexin/routes/app/index.dart';
import 'package:igflexin/routes/auth/index.dart';
import 'package:igflexin/routes/billing_setup/index.dart';
import 'package:igflexin/routes/splash/index.dart';

import 'package:provider/provider.dart';

class MainRouterController extends RouterController {
  static List<Route> _generateRoutes() {
    return [
      Route('splash', (context) {
        return Splash();
      }, clearsHistory: true),
      Route('auth', (context) {
        return Auth();
      }, clearsHistory: true),
      Route('billing_setup', (context) {
        return BillingSetup();
      }, clearsHistory: true),
      Route('app', (context) {
        return App();
      }, clearsHistory: true),
    ];
  }

  MainRouterController(BuildContext context) : super(context, _generateRoutes(), 'splash');

  UserRepository _userRepository;
  SystemBarsRepository _systembarsRepository;

  @override
  void didWidgetChangeDependencies(BuildContext context) {
    _userRepository = Provider.of<UserRepository>(context);
    _systembarsRepository = Provider.of<SystemBarsRepository>(context);

    _systembarsRepository.setNavigationBarColor(Colors.transparent);
    _systembarsRepository.setStatusBarColor(Colors.transparent);
  }

  @override
  void beforeBuild(BuildContext context) {
    UserResource user = _userRepository.user;

    switch (user.state) {
      case UserState.None:
        push('splash');
        break;
      case UserState.Unauthenticated:
        push('auth');
        break;
      case UserState.Authenticated:
        push('billing_setup', playExitAnimations: false, playOnlyLastAnimation: true);
        break;
    }
  }

  @override
  void afterPush(Route nextRoute) {
    switch (nextRoute.name) {
      case 'splash':
        print('splash');
        _systembarsRepository.setLightForeground();
        break;
      case 'auth':
        print('auth');
        _systembarsRepository.setLightForeground();
        break;
      case 'billing_setup':
        print('billing_setup');
        _systembarsRepository.setDarkForeground();
        break;
      case 'app':
        print('app');
        _systembarsRepository.setDarkForeground();
        break;
    }
  }
}
