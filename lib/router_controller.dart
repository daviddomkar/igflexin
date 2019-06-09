import 'package:flutter/widgets.dart' hide Route;

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';

import 'package:igflexin/resources/user.dart';

import 'package:igflexin/routes/app/index.dart';
import 'package:igflexin/routes/auth/index.dart';
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
      Route('app', (context) {
        return App();
      }, clearsHistory: true),
    ];
  }

  MainRouterController(BuildContext context) : super(context, _generateRoutes(), 'splash');

  /* (╯°□°）╯︵ ┻━┻ */
  @override
  void beforeBuild(BuildContext context) {
    UserResource user = Provider.of<UserRepository>(context).user;

    switch (user.state) {
      case UserState.None:
        push('splash');
        break;
      case UserState.Unauthenticated:
        push('auth');
        break;
      case UserState.Authenticated:
        push('app');
        break;
    }
  }
}
