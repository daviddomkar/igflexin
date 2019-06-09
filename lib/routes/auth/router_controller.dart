import 'package:flutter/widgets.dart' hide Route;
import 'package:igflexin/repositories/router_repository.dart';

import 'routes/intro/index.dart';
import 'routes/log_in/index.dart';
import 'routes/sign_up/index.dart';

class AuthRouterController extends RouterController {
  static List<Route> _generateRoutes() {
    return [
      Route('intro', (context) {
        print('heh');
        return Intro();
      }, clearsHistory: true),
      Route('login', (context) {
        print('hehe');
        return LogIn();
      }),
      Route('signup', (context) {
        print('hihi');
        return SignUp();
      }),
    ];
  }

  AuthRouterController(BuildContext context) : super(context, _generateRoutes(), 'intro');
}
