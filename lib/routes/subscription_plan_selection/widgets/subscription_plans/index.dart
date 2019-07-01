import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/subscription_plan.dart';
import 'package:igflexin/routes/subscription_plan_selection/widgets/subscription_plans/subscription_plan_detail.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class SubscriptionPlans extends StatefulWidget {
  SubscriptionPlans({Key key, this.orientation, this.controller, this.initialPlan})
      : super(key: key);

  final int initialPlan;
  final Orientation orientation;
  final AnimationController controller;

  @override
  _SubscriptionPlansState createState() {
    return _SubscriptionPlansState();
  }
}

class _SubscriptionPlansState extends State<SubscriptionPlans> {
  PageController _pageController;

  int _currentPage;

  Animation<double> _scale;
  Animation<double> _height;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.8, initialPage: widget.initialPlan);

    _currentPage = widget.initialPlan;

    _pageController.addListener(_pageControllerListener);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.removeListener(_pageControllerListener);
  }

  void _pageControllerListener() {
    int nextPage = _pageController.page.round();

    if (_currentPage != nextPage) {
      setState(() {
        _currentPage = nextPage;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scale = Tween(begin: 1.25, end: 1.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: new Interval(0.000, 0.5 / 2.25, curve: Curves.easeOutExpo),
    ));

    _height = Tween(
            begin: MediaQuery.of(context).size.height,
            end: ResponsivityUtils.compute(
                MediaQuery.of(context).orientation == Orientation.portrait ? 400.0 : 350.0,
                context))
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: new Interval(0.000, 0.5 / 2.25, curve: Curves.easeOutExpo),
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
            itemCount: SubscriptionPlanType.values.length,
            itemBuilder: (context, int currentIdx) {
              bool active = currentIdx == _currentPage;

              if (active) {
                Provider.of<SubscriptionRepository>(context)
                    .setSelectedPlanType(SubscriptionPlanType.values[currentIdx]);
              }

              return SubscriptionPlanDetail(
                active: active,
                planType: SubscriptionPlanType.values[currentIdx],
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
