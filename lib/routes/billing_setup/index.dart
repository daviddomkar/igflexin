import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/auth_repository.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/resources/plan.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:provider/provider.dart';

const double _BOTTOM_HEIGHT_ = 80.0;

class BillingSetup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: true,
      body: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: RouterAnimationController<MainRouterController>(
                    duration: const Duration(milliseconds: 2000),
                    builder: (context, controller) {
                      return SystemBarsInfoProvider(
                        builder: (context, child, systemBarsInfo, orientation) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context),
                                margin: EdgeInsets.only(
                                    top: systemBarsInfo.hasSoftwareNavigationBar
                                        ? systemBarsInfo.navigationBarHeight
                                        : systemBarsInfo.statusBarHeight),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    'Choose a plan.',
                                    style: TextStyle(
                                      fontSize: ResponsivityUtils.compute(40.0, context),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: SubscriptionPlans(
                                  orientation: orientation,
                                  controller: controller,
                                ),
                              ),
                              Container(
                                height: ResponsivityUtils.compute(_BOTTOM_HEIGHT_, context),
                                margin: EdgeInsets.only(
                                    bottom: systemBarsInfo.hasSoftwareNavigationBar
                                        ? systemBarsInfo.navigationBarHeight
                                        : systemBarsInfo.statusBarHeight),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: RaisedButton(
                                    highlightElevation: 0,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50.0)),
                                    color: Colors.black,
                                    child: Text(
                                      'Sign out',
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        fontSize: ResponsivityUtils.compute(16.0, context),
                                        color: Color.fromARGB(255, 223, 61, 139),
                                      ),
                                    ),
                                    onPressed: () {
                                      Provider.of<AuthRepository>(context).signOut();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SubscriptionPlans extends StatefulWidget {
  SubscriptionPlans({Key key, this.orientation, this.controller}) : super(key: key);

  final Orientation orientation;
  final AnimationController controller;

  @override
  _SubscriptionPlansState createState() {
    return _SubscriptionPlansState();
  }
}

class _SubscriptionPlansState extends State<SubscriptionPlans> {
  final PageController _pageController = PageController(viewportFraction: 0.8, initialPage: 1);

  Animation<double> _scale;

  int currentPage = 1;

  final subscriptionPlans = [
    Plan(
      name: 'Basic',
      gradientStartColor: Color.fromARGB(255, 5, 117, 230),
      gradientEndColor: Color.fromARGB(255, 0, 242, 96),
    ),
    Plan(
      name: 'Standard',
      gradientStartColor: Color.fromARGB(255, 223, 61, 139),
      gradientEndColor: Color.fromARGB(255, 255, 161, 94),
    ),
    Plan(
      name: 'Business',
      gradientStartColor: Color.fromARGB(255, 196, 113, 237),
      gradientEndColor: Color.fromARGB(255, 18, 194, 233),
    ),
    Plan(
      name: 'Business PRO',
      gradientStartColor: Color.fromARGB(255, 236, 56, 188),
      gradientEndColor: Color.fromARGB(255, 115, 3, 192),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController.addListener(_pageControllerListener);

    _scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: new Interval(0.500, 1.000, curve: Curves.elasticOut),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.removeListener(_pageControllerListener);
  }

  void _pageControllerListener() {
    int nextPage = _pageController.page.round();

    if (currentPage != nextPage) {
      setState(() {
        currentPage = nextPage;
      });
    }
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      height: widget.orientation == Orientation.portrait
          ? ResponsivityUtils.compute(400.0, context)
          : ResponsivityUtils.compute(350.0, context),
      child: PageView.builder(
        controller: _pageController,
        itemCount: subscriptionPlans.length,
        itemBuilder: (context, int currentIdx) {
          return SubscriptionPlanDetail(
            active: currentIdx == currentPage,
            plan: subscriptionPlans[currentIdx],
          );
        },
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

class SubscriptionPlanDetail extends StatelessWidget {
  SubscriptionPlanDetail({Key key, this.active, this.plan}) : super(key: key);

  final bool active;
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(
        top: active ? 0 : ResponsivityUtils.compute(40, context),
        right: active ? ResponsivityUtils.compute(10, context) : 0,
        left: active ? ResponsivityUtils.compute(10, context) : 0,
        bottom: active ? 0 : ResponsivityUtils.compute(40, context),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsivityUtils.compute(30.0, context)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          colors: [plan.gradientStartColor, plan.gradientEndColor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuint,
            margin: EdgeInsets.only(
                top: ResponsivityUtils.compute(active ? 20.0 : 10.0, context),
                bottom: ResponsivityUtils.compute(active ? 15.0 : 5.0, context)),
            child: Text(
              plan.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsivityUtils.compute(30.0, context),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: ResponsivityUtils.compute(15.0, context)),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuint,
                    padding: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(active ? 10.0 : 5.0, context),
                        horizontal: ResponsivityUtils.compute(10.0, context)),
                    child: Text(
                      '7 days free trial',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: ResponsivityUtils.compute(15.0, context)),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuint,
                    padding: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(active ? 10.0 : 5.0, context),
                        horizontal: ResponsivityUtils.compute(10.0, context)),
                    child: Text(
                      'Up to 3 Instagram accounts',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: ResponsivityUtils.compute(15.0, context)),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                      padding: EdgeInsets.symmetric(
                          vertical: ResponsivityUtils.compute(active ? 10.0 : 5.0, context),
                          horizontal: ResponsivityUtils.compute(10.0, context)),
                      child: Text(
                        'IG accounts must have at least 100 followers and 15 posts',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: ResponsivityUtils.compute(15.0, context)),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuint,
                    padding: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(active ? 10.0 : 5.0, context),
                        horizontal: ResponsivityUtils.compute(10.0, context)),
                    child: Text(
                      'Cancel anytime',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(
              top: ResponsivityUtils.compute(10.0, context),
              bottom: ResponsivityUtils.compute(20.0, context),
              left: ResponsivityUtils.compute(20.0, context),
              right: ResponsivityUtils.compute(20.0, context),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '£ 14.99 / month',
                      style: TextStyle(
                        fontSize: ResponsivityUtils.compute(20.0, context),
                        color: Colors.white,
                      ),
                    ),
                    CurvedWhiteButton(
                      child: Text(
                        'SELECT',
                        style: TextStyle(color: plan.gradientStartColor),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                Divider(
                  color: Colors.white,
                  height: 2.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '£ 149.99 / year',
                      style: TextStyle(
                        fontSize: ResponsivityUtils.compute(20.0, context),
                        color: Colors.white,
                      ),
                    ),
                    CurvedWhiteButton(
                      child: Text(
                        'SELECT',
                        style: TextStyle(color: plan.gradientStartColor),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
