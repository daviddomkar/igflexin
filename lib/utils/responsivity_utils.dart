import 'package:flutter/widgets.dart';

class ResponsivityUtils {
  static double compute(double value, BuildContext context) {
    var queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

    return devicePixelRatio < 2.625 ? value / (5.5 - devicePixelRatio) * (5.5 - 2.625) : value / devicePixelRatio * 2.625;
  }
}
