import 'package:igflexin/model/resource.dart';
import 'package:igflexin/model/subscription_plan.dart';
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
