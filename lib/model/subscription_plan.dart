import 'package:flutter/material.dart';

enum SubscriptionPlanInterval {
  Month,
  Year,
}

// ignore: missing_return
String getStringFromSubscriptionPlanInterval(
    SubscriptionPlanInterval interval) {
  switch (interval) {
    case SubscriptionPlanInterval.Month:
      return 'month';
    case SubscriptionPlanInterval.Year:
      return 'year';
  }
}

// ignore: missing_return
SubscriptionPlanInterval getSubscriptionPlanIntervalFromString(
    String interval) {
  switch (interval) {
    case 'month':
      return SubscriptionPlanInterval.Month;
    case 'year':
      return SubscriptionPlanInterval.Year;
  }
}

enum SubscriptionPlanType {
  Basic,
  Standard,
  Business,
  BusinessPRO,
}

// ignore: missing_return
String getPrettyStringFromSubscriptionPlanType(SubscriptionPlanType type) {
  switch (type) {
    case SubscriptionPlanType.Basic:
      return 'Basic';
    case SubscriptionPlanType.Standard:
      return 'Standard';
    case SubscriptionPlanType.Business:
      return 'Business';
    case SubscriptionPlanType.BusinessPRO:
      return 'Business PRO';
  }
}

// ignore: missing_return
String getStringFromSubscriptionPlanType(SubscriptionPlanType type) {
  switch (type) {
    case SubscriptionPlanType.Basic:
      return 'basic';
    case SubscriptionPlanType.Standard:
      return 'standard';
    case SubscriptionPlanType.Business:
      return 'business';
    case SubscriptionPlanType.BusinessPRO:
      return 'business_pro';
  }
}

// ignore: missing_return
SubscriptionPlanType getSubscriptionPlanTypeFromString(String type) {
  switch (type) {
    case 'basic':
      return SubscriptionPlanType.Basic;
    case 'standard':
      return SubscriptionPlanType.Standard;
    case 'business':
      return SubscriptionPlanType.Business;
    case 'business_pro':
      return SubscriptionPlanType.BusinessPRO;
  }
}

class SubscriptionPlan {
  final String name;
  final List<String> features;
  final String monthlyPrice;
  final String yearlyPrice;

  SubscriptionPlan._internal({
    @required this.name,
    @required this.features,
    @required this.monthlyPrice,
    @required this.yearlyPrice,
  });

  factory SubscriptionPlan(SubscriptionPlanType type) {
    switch (type) {
      case SubscriptionPlanType.Basic:
        return SubscriptionPlan._internal(
          name: 'Basic',
          features: [
            '7 days free trial',
            'Limited to 1 Instagram account',
            'Instagram accounts must have at least 100 followers and 15 posts',
            'Cancel anytime'
          ],
          monthlyPrice: '£ 9.99 / month',
          yearlyPrice: '£ 99.99 / year',
        );
        break;
      case SubscriptionPlanType.Standard:
        return SubscriptionPlan._internal(
          name: 'Standard',
          features: [
            '7 days free trial',
            'Up to 3 Instagram accounts',
            'Instagram accounts must have at least 100 followers and 15 posts',
            'Cancel anytime'
          ],
          monthlyPrice: '£ 14.99 / month',
          yearlyPrice: '£ 149.99 / year',
        );
        break;
      case SubscriptionPlanType.Business:
        return SubscriptionPlan._internal(
          name: 'Business',
          features: [
            '7 days free trial',
            'Up to 5 Instagram accounts',
            'No Instagram account restrictions',
            'Cancel anytime'
          ],
          monthlyPrice: '£ 19.99 / month',
          yearlyPrice: '£ 199.99 / year',
        );
        break;
      case SubscriptionPlanType.BusinessPRO:
        return SubscriptionPlan._internal(
          name: 'Business PRO',
          features: [
            '7 days free trial',
            'Up to 10 Instagram accounts',
            'No Instagram account restrictions',
            'Cancel anytime'
          ],
          monthlyPrice: '£ 29.99 / month',
          yearlyPrice: '£ 299.99 / year',
        );
        break;
    }

    return SubscriptionPlan._internal(
      name: 'Basic',
      features: [
        '7 days free trial',
        'Limited to 1 Instagram account',
        'Instagram accounts must have at least 100 followers and 15 posts',
        'Cancel anytime'
      ],
      monthlyPrice: '£ 9.99 / month',
      yearlyPrice: '£ 99.99 / year',
    );
  }
}
