import 'package:flutter/material.dart';
import 'package:igflexin/models/subscription_plan.dart';

class SubscriptionPlanTheme {
  SubscriptionPlanTheme._internal(
      {@required this.gradientStartColor, @required this.gradientEndColor});

  final Color gradientStartColor;
  final Color gradientEndColor;

  factory SubscriptionPlanTheme(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.Basic:
        return SubscriptionPlanTheme._internal(
          gradientStartColor: Color.fromARGB(255, 5, 117, 230),
          gradientEndColor: Color.fromARGB(255, 0, 242, 96),
        );
        break;
      case SubscriptionPlanType.Standard:
        return SubscriptionPlanTheme._internal(
          gradientStartColor: Color.fromARGB(255, 223, 61, 139),
          gradientEndColor: Color.fromARGB(255, 255, 161, 94),
        );
        break;
      case SubscriptionPlanType.Business:
        return SubscriptionPlanTheme._internal(
          gradientStartColor: Color.fromARGB(255, 196, 113, 237),
          gradientEndColor: Color.fromARGB(255, 18, 194, 233),
        );
        break;
      case SubscriptionPlanType.BusinessPRO:
        return SubscriptionPlanTheme._internal(
          gradientStartColor: Color.fromARGB(255, 236, 56, 188),
          gradientEndColor: Color.fromARGB(255, 115, 3, 192),
        );
        break;
    }

    return SubscriptionPlanTheme._internal(
      gradientStartColor: Color.fromARGB(255, 5, 117, 230),
      gradientEndColor: Color.fromARGB(255, 0, 242, 96),
    );
  }
}
