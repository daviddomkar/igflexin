import 'package:flutter/material.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/routes/app/router_controller.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouterAnimationController<AppRouterController>(
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return SystemBarsInfoProvider(builder: (context, child, systemBarsInfo, orientation) {
          return _Dashboard(controller, systemBarsInfo, orientation);
        });
      },
    );
  }
}

class _Dashboard extends StatefulWidget {
  _Dashboard(this.controller, this.systemBarsInfo, this.orientation);

  final AnimationController controller;
  final SystemBarsInfo systemBarsInfo;
  final Orientation orientation;

  @override
  __DashboardState createState() {
    return __DashboardState();
  }
}

class __DashboardState extends State<_Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: widget.systemBarsInfo.statusBarHeight),
          height: ResponsivityUtils.compute(72.0, context),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: ResponsivityUtils.compute(16.0, context)),
                child: Text(
                  'Accounts',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: ResponsivityUtils.compute(32.0, context),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Color.fromARGB(255, 232, 232, 232),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: widget.systemBarsInfo.navigationBarHeight),
          height: ResponsivityUtils.compute(64.0, context),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            unselectedItemColor: Colors.black,
            selectedItemColor:
                Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                title: Text('Accounts'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                title: Text('Overview'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ],
          ),
        ),
      ],
    );

    Container(
      color: Colors.white,
      child: Center(
        child: RaisedButton(
          highlightElevation: 0,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          color: Colors.black,
          child: Text(
            'Sign out',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: ResponsivityUtils.compute(16.0, context),
              color: Provider.of<SubscriptionRepository>(context).planTheme.gradientStartColor,
            ),
          ),
          onPressed: () {
            Provider.of<AuthRepository>(context).signOut();
          },
        ),
      ),
    );
  }
}
