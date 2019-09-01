import 'package:flutter/widgets.dart' hide Route;
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/routes/auth/routes/forgot_password/index.dart';

import 'routes/intro/index.dart';
import 'routes/log_in/index.dart';
import 'routes/sign_up/index.dart';

class AuthRouterController extends RouterController {
  static List<Route> _generateRoutes() {
    return [
      Route('intro', (context) {
        return Intro();
      }, clearsHistory: true),
      Route('login', (context) {
        return LogIn();
      }),
      Route('signup', (context) {
        return SignUp();
      }),
      Route('forgot_password', (context) {
        return ForgotPassword();
      }),
    ];
  }

  AuthRouterController(BuildContext context) : super(context, _generateRoutes(), 'intro');
}
