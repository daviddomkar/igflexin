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
      duration: const Duration(milliseconds: 500),
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
  _Dashboard(this.controller, this.systemBarsInfo, this.orientation)
      : contentBackgroundColor = ColorTween(
                begin: Colors.white, end: Color.fromARGB(255, 232, 232, 232))
            .animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.500, curve: Curves.easeOutExpo),
        )),
        contentOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.500, 1.000, curve: Curves.ease),
        ));

  final AnimationController controller;
  final SystemBarsInfo systemBarsInfo;
  final Orientation orientation;

  final Animation<Color> contentBackgroundColor;
  final Animation<double> contentOpacity;

  @override
  __DashboardState createState() {
    return __DashboardState();
  }
}

class __DashboardState extends State<_Dashboard> {
  var _selectedPageIndex = 1;

  Animation<double> _titleBarOffsetY;
  Animation<double> _bottomNavigationBarOffsetY;

  PageController _pageController = PageController(
    initialPage: 1,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _titleBarOffsetY = Tween(
            begin: (ResponsivityUtils.compute(72.0, context) +
                    widget.systemBarsInfo.statusBarHeight) *
                -1,
            end: 0.0)
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: new Interval(0.000, 0.500, curve: Curves.easeOutExpo),
    ));

    _bottomNavigationBarOffsetY = Tween(
            begin: ResponsivityUtils.compute(64.0, context) +
                (widget.orientation == Orientation.portrait
                    ? widget.systemBarsInfo.navigationBarHeight
                    : 0.0),
            end: 0.0)
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: new Interval(0.000, 0.500, curve: Curves.easeOutExpo),
    ));
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

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      padding: widget.orientation == Orientation.landscape &&
              widget.systemBarsInfo.hasSoftwareNavigationBar
          ? EdgeInsets.only(right: widget.systemBarsInfo.navigationBarHeight)
          : EdgeInsets.zero,
      color: widget.contentBackgroundColor.value,
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0.0, _titleBarOffsetY.value),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: widget.orientation == Orientation.landscape &&
                        widget.systemBarsInfo.hasSoftwareNavigationBar
                    ? BorderRadius.only(
                        bottomRight: Radius.circular(
                            ResponsivityUtils.compute(20.0, context)))
                    : BorderRadius.zero,
              ),
              padding:
                  EdgeInsets.only(top: widget.systemBarsInfo.statusBarHeight),
              height: ResponsivityUtils.compute(72.0, context) +
                  widget.systemBarsInfo.statusBarHeight,
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      final tween = Tween(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Interval(
                            0.500,
                            1.000,
                            curve: Curves.ease,
                          ),
                        ),
                      );

                      return ScaleTransition(
                        child: child,
                        scale: tween,
                        alignment: Alignment.centerLeft,
                      );
                    },
                    child: Container(
                      width: ResponsivityUtils.compute(200.0, context),
                      key: ValueKey(_selectedPageIndex),
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
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: ResponsivityUtils.compute(32.0, context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: widget.contentOpacity.value,
              child: Container(
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
          ),
          Transform.translate(
            offset: Offset(0.0, _bottomNavigationBarOffsetY.value),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: widget.orientation == Orientation.landscape &&
                        widget.systemBarsInfo.hasSoftwareNavigationBar
                    ? BorderRadius.only(
                        topRight: Radius.circular(
                            ResponsivityUtils.compute(20.0, context)))
                    : BorderRadius.zero,
              ),
              padding: EdgeInsets.only(
                  bottom: widget.orientation == Orientation.portrait
                      ? widget.systemBarsInfo.navigationBarHeight
                      : 0.0),
              height: ResponsivityUtils.compute(64.0, context) +
                  (widget.orientation == Orientation.portrait
                      ? widget.systemBarsInfo.navigationBarHeight
                      : 0.0),
              child: BottomNavigationBar(
                currentIndex: _selectedPageIndex,
                backgroundColor: Colors.transparent,
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: _buildAnimation,
    );
  }
}
