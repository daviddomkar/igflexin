import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/repositories/router_repository.dart';
import 'package:igflexin/repositories/subscription_repository.dart';
import 'package:igflexin/resources/subscription.dart';
import 'package:igflexin/router_controller.dart';
import 'package:igflexin/utils/responsivity_utils.dart';
import 'package:igflexin/widgets/buttons.dart';
import 'package:igflexin/widgets/dialog.dart';
import 'package:igflexin/widgets/subscription_dialog/index.dart';
import 'package:provider/provider.dart';

class SubscriptionSettingsGroup extends StatefulWidget {
  SubscriptionSettingsGroup({Key key}) : super(key: key);

  @override
  _SubscriptionSettingsGroupState createState() {
    return _SubscriptionSettingsGroupState();
  }
}

class _SubscriptionSettingsGroupState extends State<SubscriptionSettingsGroup> {
  SubscriptionRepository _subscriptionRepository;

  Subscription _cachedSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscriptionRepository = Provider.of<SubscriptionRepository>(context);

    if (_subscriptionRepository.subscription.state ==
        SubscriptionState.Active) {
      _cachedSubscription = _subscriptionRepository.subscription.data;
    }

    _subscriptionRepository.addListener(_subscriptionChanged);
  }

  void _subscriptionChanged() {
    if (_subscriptionRepository.subscription.state ==
        SubscriptionState.Active) {
      _cachedSubscription = _subscriptionRepository.subscription.data;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptionRepository.removeListener(_subscriptionChanged);
  }

  @override
  Widget build(BuildContext context) {
    print(_cachedSubscription.trialEnds);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          colors: [
            Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientStartColor,
            Provider.of<SubscriptionRepository>(context)
                .planTheme
                .gradientEndColor
          ],
        ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsivityUtils.compute(8.0, context),
        vertical: ResponsivityUtils.compute(4.0, context),
      ),
      child: Container(
        margin: EdgeInsets.all(
          ResponsivityUtils.compute(20.0, context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subscription',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsivityUtils.compute(26.0, context),
                color: Colors.white,
              ),
            ),
            Container(
              margin: EdgeInsets.all(
                ResponsivityUtils.compute(20.0, context),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(4.0, context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Plan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsivityUtils.compute(18.0, context),
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          getPrettyStringFromSubscriptionPlanType(
                              _cachedSubscription.type),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsivityUtils.compute(18.0, context),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(4.0, context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsivityUtils.compute(18.0, context),
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _cachedSubscription.trialEnds != null
                              ? 'In trial period'
                              : _cachedSubscription.paymentMethodId.length == 0
                                  ? 'Requires payment method'
                                  : getPrettyStringFromSubscriptionStatus(
                                      _cachedSubscription.status),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsivityUtils.compute(18.0, context),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((_cachedSubscription.status == 'active' ||
                          _cachedSubscription.status == 'requires_action') &&
                      _cachedSubscription.paymentMethodId.length > 0)
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(4.0, context),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment method:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  ResponsivityUtils.compute(18.0, context),
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_cachedSubscription.paymentMethodBrand[0].toUpperCase()}${_cachedSubscription.paymentMethodBrand.substring(1)}' +
                                ' card **' +
                                _cachedSubscription.paymentMethodLast4,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  ResponsivityUtils.compute(18.0, context),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if ((_cachedSubscription.status == 'active' ||
                          _cachedSubscription.status == 'requires_action') &&
                      _cachedSubscription.paymentMethodId.length > 0)
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(4.0, context),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Paying:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  ResponsivityUtils.compute(18.0, context),
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _cachedSubscription.interval ==
                                    SubscriptionPlanInterval.Month
                                ? SubscriptionPlan(_cachedSubscription.type)
                                    .monthlyPrice
                                : SubscriptionPlan(_cachedSubscription.type)
                                    .yearlyPrice,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  ResponsivityUtils.compute(18.0, context),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_cachedSubscription.status == 'active' &&
                      _cachedSubscription.nextCharge
                              .toDate()
                              .millisecondsSinceEpoch >=
                          Timestamp.now().millisecondsSinceEpoch)
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(4.0, context),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _cachedSubscription.status == 'active' &&
                                    _cachedSubscription.paymentMethodId.length >
                                        0
                                ? 'Next charge:'
                                : 'Expires:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  ResponsivityUtils.compute(18.0, context),
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            formatSubscriptionDate(
                                _cachedSubscription.nextCharge.toDate()),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  ResponsivityUtils.compute(18.0, context),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /*
                if (_cachedSubscription.status == 'active' &&
                    _cachedSubscription.paymentMethodId.length > 0)
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(2.0, context)),
                    height: ResponsivityUtils.compute(50.0, context),
                    child: CurvedTransparentButton(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Upgrade or downgrade subscription',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        showModalWidgetLight(
                            context,
                            SubscriptionDialog(
                              actionType: SubscriptionActionType.Renew,
                            ));
                      },
                    ),
                  ),
                */

                /*
                if (_cachedSubscription.status == 'active' &&
                    _cachedSubscription.paymentMethodId.length > 0)
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(2.0, context)),
                    height: ResponsivityUtils.compute(50.0, context),
                    child: CurvedTransparentButton(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Change billing cycle to ' +
                              (_cachedSubscription.interval ==
                                      SubscriptionPlanInterval.Month
                                  ? 'yearly'
                                  : 'monthly'),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        showModalWidgetLight(
                            context,
                            SubscriptionDialog(
                              actionType: SubscriptionActionType.Renew,
                            ));
                      },
                    ),
                  ),
                 */
                if (_cachedSubscription.status == 'requires_payment_method' ||
                    _cachedSubscription.paymentMethodId.length == 0)
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(2.0, context)),
                    height: ResponsivityUtils.compute(50.0, context),
                    child: CurvedTransparentButton(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Attach payment method',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        showModalWidgetLight(
                            context,
                            SubscriptionDialog(
                              actionType:
                                  SubscriptionActionType.RequiresPaymentMethod,
                            ));
                      },
                    ),
                  ),
                if (_cachedSubscription.status == 'requires_action')
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(2.0, context)),
                    height: ResponsivityUtils.compute(50.0, context),
                    child: CurvedTransparentButton(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Complete action',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        showModalWidgetLight(
                          context,
                          SubscriptionDialog(
                            routerController:
                                Router.of<MainRouterController>(context),
                            actionType: SubscriptionActionType.RequiresAction,
                          ),
                        );
                      },
                    ),
                  ),
                if (_cachedSubscription.status == 'canceled')
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(2.0, context)),
                    height: ResponsivityUtils.compute(50.0, context),
                    child: CurvedTransparentButton(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Renew subscription',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        showModalWidgetLight(
                            context,
                            SubscriptionDialog(
                              actionType: SubscriptionActionType.Renew,
                            ));
                      },
                    ),
                  ),
                if (_subscriptionRepository.couponsEnabled &&
                    _cachedSubscription.status == 'active' &&
                    _cachedSubscription.paymentMethodId.length > 0)
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(2.0, context)),
                    height: ResponsivityUtils.compute(50.0, context),
                    child: CurvedTransparentButton(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Apply coupon',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: ResponsivityUtils.compute(2.0, context)),
                  height: ResponsivityUtils.compute(50.0, context),
                  child: CurvedTransparentButton(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Manage payment methods',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () {
                      showModalWidgetLight(
                          context,
                          SubscriptionDialog(
                            actionType:
                                SubscriptionActionType.ManagePaymentMethods,
                          ));
                    },
                  ),
                ),
                if (_cachedSubscription.status != 'canceled')
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ResponsivityUtils.compute(2.0, context)),
                    height: ResponsivityUtils.compute(50.0, context),
                    child: CurvedTransparentButton(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Cancel subscription',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        showModalWidgetLight(
                            context,
                            SubscriptionDialog(
                              actionType: SubscriptionActionType.Cancel,
                            ));
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
