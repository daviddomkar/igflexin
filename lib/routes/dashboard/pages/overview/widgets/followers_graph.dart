import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class FollowersGraph extends StatefulWidget {
  @override
  _FollowersGraphState createState() {
    return _FollowersGraphState();
  }
}

class _FollowersGraphState extends State<FollowersGraph> {
  SubscriptionRepository _subscriptionRepository;
  BezierChartScale _bezierChartScale = BezierChartScale.HOURLY;
  int _redrawValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _subscriptionRepository.addListener(_redrawGraph);
  }

  void _redrawGraph() {
    setState(() {
      _redrawValue++;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptionRepository.removeListener(_redrawGraph);
  }

  @override
  Widget build(BuildContext context) {
    final fromDate = DateTime(2019, 05, 22);
    final toDate = DateTime.now();

    final date1 = DateTime.now().subtract(Duration(days: 2));
    final date2 = DateTime.now().subtract(Duration(
      days: 3,
      hours: 12,
    ));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          colors: [
            Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientStartColor,
            Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientEndColor
          ],
        ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsivityUtils.compute(8.0, context),
        vertical: ResponsivityUtils.compute(4.0, context),
      ),
      height: ResponsivityUtils.compute(240.0, context),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsivityUtils.compute(20.0, context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: ResponsivityUtils.compute(20.0, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your followers',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsivityUtils.compute(26.0, context),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                    ),
                    height: ResponsivityUtils.compute(30.0, context),
                    width: ResponsivityUtils.compute(110.0, context),
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 5.0,
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          iconEnabledColor: Colors.black,
                          style: TextStyle(
                            fontFamily: 'LatoLatin',
                            color: Colors.black,
                          ),
                          elevation: 4,
                          isDense: true,
                          items: [
                            DropdownMenuItem(
                              value: BezierChartScale.HOURLY,
                              child: Text(
                                'Hourly',
                              ),
                            ),
                            DropdownMenuItem(
                              value: BezierChartScale.WEEKLY,
                              child: Text(
                                'Weekly',
                              ),
                            ),
                            DropdownMenuItem(
                              value: BezierChartScale.MONTHLY,
                              child: Text(
                                'Monthly',
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _bezierChartScale = value;
                            });
                          },
                          value: _bezierChartScale,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: ResponsivityUtils.compute(120.0, context),
              child: BezierChart(
                key: ValueKey(_bezierChartScale.index +
                    _redrawValue +
                    MediaQuery.of(context).orientation.index),
                fromDate: fromDate,
                bezierChartScale: _bezierChartScale,
                toDate: toDate,
                selectedDate: toDate,
                series: [
                  BezierLine(
                    label: 'Followers',
                    onMissingValue: (dateTime) {
                      if (dateTime.day.isEven) {
                        return 10.0;
                      }
                      return 5.0;
                    },
                    data: [
                      DataPoint<DateTime>(value: 10, xAxis: date1),
                      DataPoint<DateTime>(value: 50, xAxis: date2),
                    ],
                  ),
                ],
                config: BezierChartConfig(
                  pinchZoom: false,
                  bubbleIndicatorTitleStyle: TextStyle(
                    fontFamily: 'LatoLatin',
                    color: Colors.black,
                  ),
                  bubbleIndicatorLabelStyle: TextStyle(
                    fontFamily: 'LatoLatin',
                    color: Colors.black,
                  ),
                  bubbleIndicatorValueStyle: TextStyle(
                    fontFamily: 'LatoLatin',
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  yAxisTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                  xAxisTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                  verticalIndicatorStrokeWidth: 3.0,
                  showVerticalIndicator: false,
                  showDataPoints: true,
                  footerHeight: ResponsivityUtils.compute(52.0, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class FollowersGraph extends StatefulWidget {
  @override
  _FollowersGraphState createState() {
    return _FollowersGraphState();
  }
}

class _FollowersGraphState extends State<FollowersGraph> {
  SubscriptionRepository _subscriptionRepository;
  BezierChartScale _bezierChartScale = BezierChartScale.HOURLY;
  int _redrawValue = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
    _subscriptionRepository.addListener(_redrawGraph);
  }

  void _redrawGraph() {
    setState(() {
      _redrawValue++;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptionRepository.removeListener(_redrawGraph);
  }

  @override
  Widget build(BuildContext context) {
    final fromDate = DateTime(2019, 05, 22);
    final toDate = DateTime.now();

    final date1 = DateTime.now().subtract(Duration(days: 2));
    final date2 = DateTime.now().subtract(Duration(
      days: 3,
      hours: 12,
    ));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsivityUtils.compute(8.0, context),
        vertical: ResponsivityUtils.compute(4.0, context),
      ),
      height: ResponsivityUtils.compute(240.0, context),
      child: Container(
        margin: EdgeInsets.all(
          ResponsivityUtils.compute(20.0, context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your followers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsivityUtils.compute(26.0, context),
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Provider.of<SubscriptionRepository>(context)
                        .planTheme
                        .gradientEndColor,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 1.0],
                        colors: [
                          Provider.of<SubscriptionRepository>(context)
                              .planTheme
                              .gradientStartColor,
                          Provider.of<SubscriptionRepository>(context)
                              .planTheme
                              .gradientEndColor
                        ],
                      ),
                    ),
                    height: ResponsivityUtils.compute(30.0, context),
                    width: ResponsivityUtils.compute(110.0, context),
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 5.0,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        iconEnabledColor: Colors.white,
                        style: TextStyle(
                          fontFamily: 'LatoLatin',
                          color: Colors.white,
                        ),
                        elevation: 4,
                        isDense: true,
                        items: [
                          DropdownMenuItem(
                            value: BezierChartScale.HOURLY,
                            child: Text(
                              'Hourly',
                            ),
                          ),
                          DropdownMenuItem(
                            value: BezierChartScale.WEEKLY,
                            child: Text(
                              'Weekly',
                            ),
                          ),
                          DropdownMenuItem(
                            value: BezierChartScale.MONTHLY,
                            child: Text(
                              'Monthly',
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _bezierChartScale = value;
                          });
                        },
                        value: _bezierChartScale,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: ResponsivityUtils.compute(120.0, context),
              child: BezierChart(
                key: ValueKey(_bezierChartScale.index +
                    _redrawValue +
                    MediaQuery.of(context).orientation.index),
                fromDate: fromDate,
                bezierChartScale: _bezierChartScale,
                toDate: toDate,
                selectedDate: toDate,
                series: [
                  BezierLine(
                    lineColor:
                        _subscriptionRepository.planTheme.gradientStartColor,
                    label: 'Followers',
                    onMissingValue: (dateTime) {
                      if (dateTime.day.isEven) {
                        return 10.0;
                      }
                      return 5.0;
                    },
                    data: [
                      DataPoint<DateTime>(value: 10, xAxis: date1),
                      DataPoint<DateTime>(value: 50, xAxis: date2),
                    ],
                  ),
                ],
                config: BezierChartConfig(
                  pinchZoom: false,
                  bubbleIndicatorTitleStyle: TextStyle(
                    fontFamily: 'LatoLatin',
                    color: Colors.white,
                  ),
                  bubbleIndicatorLabelStyle: TextStyle(
                    fontFamily: 'LatoLatin',
                    color: Colors.white,
                  ),
                  bubbleIndicatorValueStyle: TextStyle(
                    fontFamily: 'LatoLatin',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  yAxisTextStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  xAxisTextStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  xLinesColor:
                      _subscriptionRepository.planTheme.gradientStartColor,
                  verticalIndicatorStrokeWidth: 3.0,
                  showVerticalIndicator: false,
                  showDataPoints: true,
                  footerHeight: ResponsivityUtils.compute(52.0, context),
                  bubbleIndicatorColor:
                      _subscriptionRepository.planTheme.gradientEndColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
