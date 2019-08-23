import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:igflexin/model/resource.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:meta/meta.dart';

class Subscription {
  Subscription({
    this.status,
    this.type,
    this.interval,
    this.nextCharge,
    this.trialEnds,
    this.paymentIntentSecret,
    this.paymentMethodId,
    this.paymentMethodBrand,
    this.paymentMethodLast4,
  });

  final String status;
  final SubscriptionPlanType type;
  final SubscriptionPlanInterval interval;
  final Timestamp nextCharge;
  final Timestamp trialEnds;
  final String paymentIntentSecret;
  final String paymentMethodId;
  final String paymentMethodBrand;
  final String paymentMethodLast4;
}

enum SubscriptionState { None, Inactive, Active }

class SubscriptionResource extends Resource<SubscriptionState, Subscription> {
  SubscriptionResource({@required SubscriptionState state, Subscription data})
      : super(state: state, data: data);
}

String getPrettyStringFromSubscriptionStatus(String status) {
  switch (status) {
    case 'active':
      return 'Active';
    case 'requires_payment_method':
      return 'Payment method required';
    case 'requires_action':
      return 'Action required';
    case 'canceled':
      return 'Canceled';
    default:
      return 'Unknown';
  }
}

String formatSubscriptionDate(DateTime dateTime) {
  return dateTime.day.toString() +
      _getDayOfMonthSuffix(dateTime.day) +
      ' ' +
      _getMonthName(dateTime.month) +
      ' ' +
      dateTime.year.toString();
}

String _getDayOfMonthSuffix(final int n) {
  if (n >= 11 && n <= 13) {
    return "th";
  }
  switch (n % 10) {
    case 1:
      return "st";
    case 2:
      return "nd";
    case 3:
      return "rd";
    default:
      return "th";
  }
}

String _getMonthName(final int n) {
  switch (n) {
    case 1:
      return "January";
      break;
    case 2:
      return "February";
      break;
    case 3:
      return "March";
      break;
    case 4:
      return "April";
      break;
    case 5:
      return "May";
      break;
    case 6:
      return "June";
      break;
    case 7:
      return "July";
      break;
    case 8:
      return "August";
      break;
    case 9:
      return "September";
      break;
    case 10:
      return "October";
      break;
    case 11:
      return "November";
      break;
    case 12:
      return "December";
      break;
  }
}
