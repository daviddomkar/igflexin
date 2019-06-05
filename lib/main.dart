import 'package:flutter/material.dart' hide Route;
import 'package:flutter/services.dart';

import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/user_repository.dart';

import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/router_controller.dart';

import 'package:provider/provider.dart';

void main() => runApp(IGFlexinApp());

class IGFlexinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    return MultiProvider(
      providers: [
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
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'LatoLatin',
          primaryColor: Color.fromARGB(255, 223, 61, 139),
          accentColor: Color.fromARGB(255, 255, 161, 94),
        ),
        home: Router<MainRouterController>(
          builder: (_) => MainRouterController(),
        ),
      ),
    );
  }
}
