import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_stripe_sdk/model/card.dart';
import 'package:flutter_stripe_sdk/model/payment_method.dart';
import 'package:flutter_stripe_sdk/model/payment_method_create_params.dart';
import 'package:igflexin/core/server.dart';

import 'package:igflexin/model/subscription_plan.dart';
import 'package:igflexin/model/subscription_plan_theme.dart';
import 'package:igflexin/resources/subscription.dart';

import 'package:flutter_stripe_sdk/stripe.dart';
import 'package:flutter_stripe_sdk/payment_configuration.dart';
import 'package:flutter_stripe_sdk/customer_session.dart';
import 'package:flutter_stripe_sdk/ephemeral_key_update_listener.dart';

class SubscriptionRepository with ChangeNotifier {
  SubscriptionRepository()
      : _subscription = SubscriptionResource(state: SubscriptionState.None, data: null),
        _auth = FirebaseAuth.instance,
        _firestore = Firestore.instance,
        _customerSession = null,
        _isApplePayAvailable = false,
        _isGooglePayAvailable = false {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);

    PaymentConfiguration.init('pk_test_U7q3vkJbTG0ROvB1IHEznZ4s00haOEFHjX');
    _stripe = Stripe(PaymentConfiguration.instance.publishableKey);

    // TODO make this actually true

    if (Platform.isIOS) {
      _isApplePayAvailable = false;
    }

    if (Platform.isAndroid) {
      _isGooglePayAvailable = false;
    }
  }

  SubscriptionPlanTheme _planTheme = SubscriptionPlanTheme(SubscriptionPlanType.Standard);
  SubscriptionPlanType _selectedPlanType = SubscriptionPlanType.Standard;
  SubscriptionPlanInterval _selectedPlanInterval = SubscriptionPlanInterval.Month;

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

  bool get isApplePayAvailable => _isApplePayAvailable;
  bool get isGooglePayAvailable => _isGooglePayAvailable;

  StreamSubscription<FirebaseUser> _authSubscription;
  StreamSubscription<DocumentSnapshot> _userDataSubscription;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _endCustomerSession();
      _subscription = SubscriptionResource(state: SubscriptionState.None, data: null);
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
      if (data.data.containsKey('activeSubscription')) {
        _subscription = SubscriptionResource(
            state: SubscriptionState.Active,
            data: Subscription(
              interval: getSubscriptionPlanIntervalFromString(
                data.data['activeSubscription']['interval'] as String,
              ),
              type: getSubscriptionPlanTypeFromString(
                data.data['activeSubscription']['type'] as String,
              ),
            ));
      } else {
        _subscription = SubscriptionResource(state: SubscriptionState.Inactive, data: null);
      }
    } else {
      _subscription = SubscriptionResource(state: SubscriptionState.None, data: null);
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
    if (_customerSession == null) {
      await _beginCustomerSession();
    }

    if ((await _customerSession.retrieveCurrentCustomer()).id !=
        (await _firestore.collection('users').document((await _auth.currentUser()).uid).get())
            .data['customerId']) {
      await _restartCustomerSession();
    }

    return await _customerSession.getPaymentMethods(type: PaymentMethodType.Card);
  }

  Future<void> addCard(Card card, PaymentMethodBillingDetails billingDetails) async {
    final paymentMethodCreateParams = PaymentMethodCreateParams.create(
      card: card.toPaymentMethodParamsCard(),
      billingDetails: billingDetails,
    );

    final paymentMethod = await _stripe.createPaymentMethod(paymentMethodCreateParams);

    await _customerSession.attachPaymentMethod(id: paymentMethod.id);
    await _customerSession.updateCurrentCustomer();
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
            keyUpdateListener.onKeyUpdateFailure(2, "Ephemeral key creation failed.");
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

/*
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
  }*/
}
