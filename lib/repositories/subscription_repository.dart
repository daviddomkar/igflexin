import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe_sdk/customer_session.dart';
import 'package:flutter_stripe_sdk/ephemeral_key_update_listener.dart';
import 'package:flutter_stripe_sdk/model/card.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:flutter_stripe_sdk/model/payment_method_create_params.dart';
import 'package:flutter_stripe_sdk/payment_configuration.dart';
import 'package:flutter_stripe_sdk/stripe.dart';
import 'package:igflexin/core/server.dart';
import 'package:igflexin/model/payment_error.dart';
import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/model/subscription_plan_theme.dart';
import 'package:igflexin/resources/subscription.dart';

class SubscriptionRepository with ChangeNotifier {
  SubscriptionRepository()
      : _subscription =
            SubscriptionResource(state: SubscriptionState.None, data: null),
        _auth = FirebaseAuth.instance,
        _firestore = Firestore.instance,
        _customerSession = null,
        _isApplePayAvailable = false,
        _isGooglePayAvailable = false,
        _couponsEnabled = false {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);

    PaymentConfiguration.init('pk_live_quXubQm5xOZXtEr53iq5fmHs00pse8eiUq');
    _stripe = Stripe(PaymentConfiguration.instance.publishableKey);

    // TODO make this actually true

    if (Platform.isIOS) {
      _isApplePayAvailable = false;
    }

    if (Platform.isAndroid) {
      _isGooglePayAvailable = false;
    }

    _couponsEnabled = false;
  }

  SubscriptionPlanTheme _planTheme =
      SubscriptionPlanTheme(SubscriptionPlanType.Standard);
  SubscriptionPlanType _selectedPlanType = SubscriptionPlanType.Standard;
  SubscriptionPlanInterval _selectedPlanInterval =
      SubscriptionPlanInterval.Month;

  SubscriptionPlanTheme get planTheme => _planTheme;
  SubscriptionPlanType get selectedPlanType => _selectedPlanType;
  SubscriptionPlanInterval get selectedPlanInterval => _selectedPlanInterval;

  SubscriptionResource _subscription;
  SubscriptionResource get subscription => _subscription;

  FirebaseAuth _auth;
  Firestore _firestore;

  Stripe _stripe;
  CustomerSession _customerSession;

  bool _isApplePayAvailable;
  bool _isGooglePayAvailable;
  bool _couponsEnabled;

  bool get isApplePayAvailable => _isApplePayAvailable;
  bool get isGooglePayAvailable => _isGooglePayAvailable;
  bool get couponsEnabled => _couponsEnabled;

  StreamSubscription<FirebaseUser> _authSubscription;
  StreamSubscription<DocumentSnapshot> _userDataSubscription;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _endCustomerSession();
      _subscription =
          SubscriptionResource(state: SubscriptionState.None, data: null);
      if (_userDataSubscription != null) {
        _userDataSubscription.cancel();
      }
      notifyListeners();
    } else {
      _userDataSubscription = _firestore
          .collection('users')
          .document(firebaseUser.uid)
          .snapshots()
          .listen(_onUserDataChanged);
    }
  }

  Future<void> _onUserDataChanged(DocumentSnapshot data) async {
    if (data.exists) {
      _beginCustomerSession();
      if (data.data.containsKey('subscription') &&
          data.data['subscription'] != null) {
        _subscription = SubscriptionResource(
            state: SubscriptionState.Active,
            data: Subscription(
              status: data.data['subscription']['status'] as String,
              interval: getSubscriptionPlanIntervalFromString(
                data.data['subscription']['interval'] as String,
              ),
              type: getSubscriptionPlanTypeFromString(
                data.data['subscription']['type'] as String,
              ),
              nextCharge: data.data['subscription']['nextCharge'],
              trialEnds: data.data['subscription']['trialEnds'],
              paymentIntentSecret: data.data['subscription']
                  ['paymentIntentSecret'],
              paymentMethodId: data.data['subscription']['paymentMethodId'],
              paymentMethodBrand: data.data['subscription']
                  ['paymentMethodBrand'],
              paymentMethodLast4: data.data['subscription']
                  ['paymentMethodLast4'],
            ));

        _planTheme = SubscriptionPlanTheme(_subscription.data.type);
      } else {
        _planTheme = SubscriptionPlanTheme(_selectedPlanType);
        _subscription =
            SubscriptionResource(state: SubscriptionState.Inactive, data: null);
      }
    } else {
      _subscription =
          SubscriptionResource(state: SubscriptionState.None, data: null);
      _planTheme = SubscriptionPlanTheme(_selectedPlanType);
    }
    notifyListeners();
  }

  void setSelectedPlanType(SubscriptionPlanType type) {
    if (_selectedPlanType == type) return;

    _selectedPlanType = type;
    _planTheme = SubscriptionPlanTheme(_selectedPlanType);
  }

  void setSelectedPlanInterval(SubscriptionPlanInterval interval) {
    _selectedPlanInterval = interval;
  }

  @override
  void dispose() {
    if (_userDataSubscription != null) {
      _userDataSubscription.cancel();
    }

    _authSubscription.cancel();
    super.dispose();
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    await _checkCustomerSession();

    return await _customerSession.getPaymentMethods(
        type: PaymentMethodType.Card);
  }

  Future<void> addCard(
      Card card, PaymentMethodBillingDetails billingDetails) async {
    final paymentMethodCreateParams = PaymentMethodCreateParams.create(
      card: card.toPaymentMethodParamsCard(),
      billingDetails: billingDetails,
    );

    final paymentMethod =
        await _stripe.createPaymentMethod(paymentMethodCreateParams);

    await _checkCustomerSession();
    await _customerSession.attachPaymentMethod(id: paymentMethod.id);
    await _customerSession.updateCurrentCustomer();
  }

  Future<void> removePaymentMethod(PaymentMethod paymentMethod) async {
    await _checkCustomerSession();
    await _customerSession.detachPaymentMethod(id: paymentMethod.id);
    await _customerSession.updateCurrentCustomer();
  }

  Future<void> purchaseSelectedSubscriptionPlan(
      PaymentMethod paymentMethod) async {
    await _checkCustomerSession();
    final result = await Server.purchaseSubscription(
      paymentMethodId: paymentMethod.id,
      subscriptionInterval:
          getStringFromSubscriptionPlanInterval(_selectedPlanInterval),
      subscriptionType: getStringFromSubscriptionPlanType(_selectedPlanType),
    );

    if (result['status'] == 'requires_action') {
      throw new PaymentErrorException(
          PaymentErrorType.RequiresAction, result['clientSecret']);
    } else if (result['status'] == 'requires_payment_method') {
      throw new PaymentErrorException(
          PaymentErrorType.RequiresPaymentMethod, null);
    }
  }

  Future<void> authenticatePayment(String paymentIntentSecret) async {
    await _checkCustomerSession();
    await _stripe.authenticatePayment(paymentIntentSecret);
  }

  Future<bool> attachPaymentMethod(PaymentMethod paymentMethod) async {
    await _checkCustomerSession();
    final result =
        await Server.attachPaymentMethod(paymentMethodId: paymentMethod.id);

    return result['requiresPayment'];
  }

  Future<void> payInvoice(PaymentMethod paymentMethod) async {
    await _checkCustomerSession();
    await Server.payInvoice(paymentMethodId: paymentMethod.id);
  }

  Future<void> cancelSubscription() async {
    await _checkCustomerSession();
    await Server.cancelSubscription();
  }

  Future<void> renewSubscription() async {
    await _checkCustomerSession();
    await Server.renewSubscription();
  }

  Future<void> _beginCustomerSession() async {
    await CustomerSession.initCustomerSessionUsingFunction(
      (String apiVersion, EphemeralKeyUpdateListener keyUpdateListener) async {
        try {
          var rawKey = await Server.createEphemeralKey(
            apiVersion: apiVersion,
          );
          keyUpdateListener.onKeyUpdate(rawKey);
          print("Key updated successfully.");
        } catch (e) {
          if (e is FormatException) {
            keyUpdateListener.onKeyUpdateFailure(0, "No internet connection.");
            print("No internet connection.");
          } else if (e is CloudFunctionsException) {
            keyUpdateListener.onKeyUpdateFailure(1, "Internal server error.");
            print("Internal server error.");
          } else {
            keyUpdateListener.onKeyUpdateFailure(
                2, "Ephemeral key creation failed.");
            print("Ephemeral key creation failed.");
          }
        }
      },
    );
    _customerSession = CustomerSession.instance;
  }

  Future<void> _endCustomerSession() async {
    if (_customerSession != null) {
      await CustomerSession.endCustomerSession();
      _customerSession = null;
    }
  }

  Future<void> _restartCustomerSession() async {
    await _endCustomerSession();
    await _beginCustomerSession();
  }

  Future<void> _checkCustomerSession() async {
    if (_customerSession == null) {
      await _beginCustomerSession();
    }

    if ((await _customerSession.retrieveCurrentCustomer()).id !=
        (await _firestore
                .collection('users')
                .document((await _auth.currentUser()).uid)
                .get())
            .data['customerId']) {
      await _restartCustomerSession();
    }
  }
}

// ignore: missing_return
int getMaxAccountLimitFromSubscriptionPlanType(SubscriptionPlanType type) {
  switch (type) {
    case SubscriptionPlanType.Basic:
      return 1;
    case SubscriptionPlanType.Standard:
      return 3;
    case SubscriptionPlanType.Business:
      return 5;
    case SubscriptionPlanType.BusinessPRO:
      return 10;
  }
}
