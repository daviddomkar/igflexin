import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:provider/provider.dart';

class TotalFollowersGraph extends StatefulWidget {
  @override
  _TotalFollowersGraphState createState() {
    return _TotalFollowersGraphState();
  }
}

class _TotalFollowersGraphState extends State<TotalFollowersGraph> {
  SubscriptionRepository _subscriptionRepository;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);
  }

  @override
  void dispose() {
    super.dispose();
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
            Text(
              'Total followers',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsivityUtils.compute(26.0, context),
              ),
            ),
            Container(
              height: ResponsivityUtils.compute(120.0, context),
              child: BezierChart(
                fromDate: fromDate,
                bezierChartScale: BezierChartScale.WEEKLY,
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
