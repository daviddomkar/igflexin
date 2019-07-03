import 'package:igflexin/models/resource.dart';
import 'package:igflexin/models/subscription_plan.dart';
import 'package:meta/meta.dart';

class Subscription {
  Subscription({this.type, this.interval});

  final SubscriptionPlanType type;
  final SubscriptionPlanInterval interval;
}

enum SubscriptionState { None, Inactive, Active }

class SubscriptionResource extends Resource<SubscriptionState, Subscription> {
  SubscriptionResource({@required SubscriptionState state, Subscription data})
      : super(state: state, data: data);
}
