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
      }),
      Route('auth', (context) {
        return Auth();
      }),
      Route('app', (context) {
        return App();
      }),
    ];
  }

  MainRouterController() : super(_generateRoutes(), 'splash');

  /* (╯°□°）╯︵ ┻━┻ */
  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, value, child) {
        switch (value.user.state) {
          case UserState.None:
            switchRoute('splash');
            break;
          case UserState.Unauthenticated:
            switchRoute('auth');
            break;
          case UserState.Authenticated:
            switchRoute('app');
            break;
        }

        return super.build(context);
      },
    );
  }
}
