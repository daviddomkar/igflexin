import 'package:flutter/widgets.dart';

class Utils {
  static double computeResponsivity(double value, BuildContext context) {

    var queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

    return devicePixelRatio < 2.625 ? value / (5.0 - devicePixelRatio) * (5.0 - 2.625) : value;
  }
}
