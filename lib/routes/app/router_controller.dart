import 'package:flutter/widgets.dart' hide Route;
import 'package:igflexin/repositories/router_repository.dart';

import 'routes/dashboard/index.dart';
import 'routes/settings/index.dart';

class AppRouterController extends RouterController {
  static List<Route> _generateRoutes() {
    return [
      Route('dashboard', (context) {
        return Dashboard();
      }, clearsHistory: true),
      Route('settings', (context) {
        return Settings();
      }),
    ];
  }

  AppRouterController(BuildContext context) : super(context, _generateRoutes(), 'dashboard');
}
