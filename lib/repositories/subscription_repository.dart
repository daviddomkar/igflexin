import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:igflexin/models/subscription_plan.dart';
import 'package:igflexin/models/subscription_plan_theme.dart';

class SubscriptionRepository with ChangeNotifier {
  SubscriptionRepository() : _functions = CloudFunctions.instance;

  SubscriptionPlanType _selectedPlanType = SubscriptionPlanType.Standard;
  SubscriptionPlanInterval _selectedPlanInterval = SubscriptionPlanInterval.Month;

  SubscriptionPlanTheme _planTheme = SubscriptionPlanTheme(SubscriptionPlanType.Standard);

  final CloudFunctions _functions;

  void setSelectedPlanType(SubscriptionPlanType type) {
    if (_selectedPlanType == type) return;

    _selectedPlanType = type;
    _planTheme = SubscriptionPlanTheme(_selectedPlanType);
  }

  void setSelectedPlanInterval(SubscriptionPlanInterval interval) {
    _selectedPlanInterval = interval;
  }

  Future<void> purchaseSubscription() async {
    HttpsCallable callable =
        _functions.getHttpsCallable(functionName: 'stripeInitialSubscriptionPurchase');

    try {
      await callable.call(<String, String>{
        'subscription_interval': getSubscriptionPlanIntervalString(_selectedPlanInterval),
        'subscription_type': getSubscriptionPlanTypeString(_selectedPlanType),
      });
    } catch (exception) {
      if (exception is CloudFunctionsException) {
        print(exception.message);
      }
    }
  }

  SubscriptionPlanTheme get planTheme => _planTheme;
  SubscriptionPlanType get selectedPlanType => _selectedPlanType;
  SubscriptionPlanInterval get selectedPlanInterval => _selectedPlanInterval;
}
