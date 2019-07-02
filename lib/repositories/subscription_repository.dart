import 'package:flutter/widgets.dart';
import 'package:igflexin/resources/subscription_plan.dart';
import 'package:igflexin/resources/subscription_plan_theme.dart';

class SubscriptionRepository with ChangeNotifier {
  SubscriptionPlanType _selectedPlanType = SubscriptionPlanType.Standard;
  SubscriptionPlanInterval _selectedPlanInterval = SubscriptionPlanInterval.Month;

  SubscriptionPlanTheme _planTheme = SubscriptionPlanTheme(SubscriptionPlanType.Standard);

  void setSelectedPlanType(SubscriptionPlanType type) {
    if (_selectedPlanType == type) return;

    _selectedPlanType = type;
    _planTheme = SubscriptionPlanTheme(_selectedPlanType);
  }

  void setSelectedPlanInterval(SubscriptionPlanInterval interval) {
    _selectedPlanInterval = interval;
  }

  SubscriptionPlanTheme get planTheme => _planTheme;
  SubscriptionPlanType get selectedPlanType => _selectedPlanType;
  SubscriptionPlanInterval get selectedPlanInterval => _selectedPlanInterval;

  SubscriptionRepository();
}
