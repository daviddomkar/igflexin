import 'package:flutter/material.dart';
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/routes/app/router_controller.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/accounts/index.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/overview/index.dart';
import 'package:igflexin/routes/app/routes/dashboard/pages/settings/index.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouterAnimationController<AppRouterController>(
      duration: const Duration(milliseconds: 2000),
      builder: (context, controller) {
        return SystemBarsInfoProvider(
            builder: (context, child, systemBarsInfo, orientation) {
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

  final Animation<Offset> titleBarOffset;
  final Animation<Offset> bottomNavigationBarOffset;
  final Animation<Color> contentBackgroundColor;
  final Animation<double> contentOpacity;

  @override
  __DashboardState createState() {
    return __DashboardState();
  }
}

class __DashboardState extends State<_Dashboard> {
  var _selectedPageIndex = 1;

  PageController _pageController = PageController(
    initialPage: 1,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
  }

  void _pageChanged(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _bottomTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
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
                margin: EdgeInsets.only(
                    left: ResponsivityUtils.compute(16.0, context)),
                child: Text(
                  (() {
                    switch (_selectedPageIndex) {
                      case 0:
                        return 'Accounts';
                      case 1:
                        return 'Overview';
                      case 2:
                        return 'Settings';
                    }
                    return 'Unknown';
                  })(),
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
            child: PageView(
              controller: _pageController,
              onPageChanged: _pageChanged,
              children: [
                Accounts(),
                Overview(),
                Settings(),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: widget.orientation == Orientation.portrait
                  ? widget.systemBarsInfo.navigationBarHeight
                  : 0.0),
          height: ResponsivityUtils.compute(64.0, context),
          child: BottomNavigationBar(
            currentIndex: _selectedPageIndex,
            backgroundColor: Colors.white,
            elevation: 0.0,
            unselectedItemColor: Colors.black,
            selectedItemColor: Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientStartColor,
            onTap: (index) {
              _bottomTapped(index);
            },
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
  }
}
