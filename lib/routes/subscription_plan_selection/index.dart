import 'package:flutter/material.dart' hide Route, Title;
import 'package:flutter_system_bars/flutter_system_bars.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/resources/plan.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/routes/subscription_plan_selection/widgets/sign_out_button.dart';
import 'package:igflexin/routes/subscription_plan_selection/widgets/title.dart';
import 'package:igflexin/utils/responsivity_utils.dart';

const double _BOTTOM_HEIGHT_ = 80.0;

class SubscriptionPlanSelection extends StatelessWidget {
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
                              Title(
                                controller: controller,
                                systemBarsInfo: systemBarsInfo,
                              ),
                              Center(
                                child: SubscriptionPlans(
                                  orientation: orientation,
                                  controller: controller,
                                ),
                              ),
                              SignOutButton(
                                controller: controller,
                                systemBarsInfo: systemBarsInfo,
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

  int currentPage = 1;

  Animation<double> _scale;
  Animation<double> _height;

  final subscriptionPlans = [
    Plan(
      name: 'Basic',
      features: [
        '7 days free trial',
        'Limited to 1 Instagram account',
        'Instagram accounts must have at least 100 followers and 15 posts',
        'Cancel anytime'
      ],
      monthlyPrice: '£ 9.99 / month',
      yearlyPrice: '£ 99.99 / year',
      gradientStartColor: Color.fromARGB(255, 5, 117, 230),
      gradientEndColor: Color.fromARGB(255, 0, 242, 96),
    ),
    Plan(
      name: 'Standard',
      features: [
        '7 days free trial',
        'Up to 3 Instagram accounts',
        'Instagram accounts must have at least 100 followers and 15 posts',
        'Cancel anytime'
      ],
      monthlyPrice: '£ 14.99 / month',
      yearlyPrice: '£ 149.99 / year',
      gradientStartColor: Color.fromARGB(255, 223, 61, 139),
      gradientEndColor: Color.fromARGB(255, 255, 161, 94),
    ),
    Plan(
      name: 'Business',
      features: [
        '7 days free trial',
        'Up to 5 Instagram accounts',
        'No Instagram account restrictions',
        'Cancel anytime'
      ],
      monthlyPrice: '£ 19.99 / month',
      yearlyPrice: '£ 199.99 / year',
      gradientStartColor: Color.fromARGB(255, 196, 113, 237),
      gradientEndColor: Color.fromARGB(255, 18, 194, 233),
    ),
    Plan(
      name: 'Business PRO',
      features: [
        '7 days free trial',
        'Up to 10 Instagram accounts',
        'No Instagram account restrictions',
        'Cancel anytime'
      ],
      monthlyPrice: '£ 29.99 / month',
      yearlyPrice: '£ 299.99 / year',
      gradientStartColor: Color.fromARGB(255, 236, 56, 188),
      gradientEndColor: Color.fromARGB(255, 115, 3, 192),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController.addListener(_pageControllerListener);
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scale = Tween(begin: 1.25, end: 1.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: new Interval(0.000, 0.250, curve: Curves.easeOutExpo),
    ));

    _height = Tween(
            begin: MediaQuery.of(context).size.height,
            end: ResponsivityUtils.compute(
                MediaQuery.of(context).orientation == Orientation.portrait ? 400.0 : 350.0,
                context))
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: new Interval(0.000, 0.250, curve: Curves.easeOutExpo),
    ));
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      height: _height.value,
      child: Container(
        child: Transform.scale(
          scale: _scale.value,
          child: PageView.builder(
            controller: _pageController,
            itemCount: subscriptionPlans.length,
            itemBuilder: (context, int currentIdx) {
              return SubscriptionPlanDetail(
                active: currentIdx == currentPage,
                plan: subscriptionPlans[currentIdx],
                controller: widget.controller,
              );
            },
          ),
        ),
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
  SubscriptionPlanDetail({Key key, this.active, this.plan, this.controller})
      : sideMargin = Tween(begin: 0.0, end: 10.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOutExpo),
        )),
        borderRadius = Tween(begin: 0.0, end: 30.0).animate(CurvedAnimation(
          parent: controller,
          curve: new Interval(0.000, 0.250, curve: Curves.easeOutExpo),
        )),
        super(key: key);

  final bool active;
  final Plan plan;

  final AnimationController controller;

  final Animation<double> sideMargin;
  final Animation<double> borderRadius;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(
        top: active ? 0 : ResponsivityUtils.compute(40, context),
        right: active ? ResponsivityUtils.compute(sideMargin.value, context) : 0,
        left: active ? ResponsivityUtils.compute(sideMargin.value, context) : 0,
        bottom: active ? 0 : ResponsivityUtils.compute(40, context),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            ResponsivityUtils.compute(active ? borderRadius.value : 30.0, context)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          colors: [plan.gradientStartColor, plan.gradientEndColor],
        ),
      ),
      /*
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
              for (var feature in plan.features)
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
                          feature,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuint,
            margin: EdgeInsets.only(
              top: ResponsivityUtils.compute(active ? 10.0 : 5.0, context),
              bottom: ResponsivityUtils.compute(active ? 20.0 : 5.0, context),
              left: ResponsivityUtils.compute(20.0, context),
              right: ResponsivityUtils.compute(20.0, context),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.monthlyPrice,
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
                      onPressed: () {
                        Provider.of<AuthRepository>(context).signOut();
                      },
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
                      plan.yearlyPrice,
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
                      onPressed: () {
                        Provider.of<AuthRepository>(context).signOut();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),*/
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: _buildAnimation,
    );
  }
}
