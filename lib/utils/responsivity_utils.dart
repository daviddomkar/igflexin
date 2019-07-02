import 'package:flutter/widgets.dart';

import 'dart:io' show Platform;

class ResponsivityUtils {
  static double compute(double value, BuildContext context) {
    var queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    if (Platform.isAndroid) {
      // Android-specific code
      return devicePixelRatio < 2.625
          ? value / (5.5 - devicePixelRatio) * (5.5 - 2.625)
          : value / devicePixelRatio * 2.625;
    } else if (Platform.isIOS) {
      // iOS-specific code
      return devicePixelRatio < 3.0
          ? value / (14.0 - devicePixelRatio) * (14.0 - 3.0)
          : value / devicePixelRatio * 3.0;
    } else {
      return devicePixelRatio < 2.625
          ? value / (5.5 - devicePixelRatio) * (5.5 - 2.625)
          : value / devicePixelRatio * 2.625;
    }
  }
}
