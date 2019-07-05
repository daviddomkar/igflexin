import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/widgets.dart';
import 'package:igflexin/core/server.dart';

import 'package:igflexin/models/subscription_plan.dart';
import 'package:igflexin/models/subscription_plan_theme.dart';
import 'package:igflexin/resources/subscription.dart';

import 'package:flutter_stripe/stripe.dart';
import 'package:flutter_stripe/payment_configuration.dart';
import 'package:flutter_stripe/customer_session.dart';
import 'package:flutter_stripe/ephemeral_key_provider.dart';
import 'package:flutter_stripe/ephemeral_key_update_listener.dart';

class SubscriptionRepository with ChangeNotifier {
  SubscriptionRepository()
      : _subscription = SubscriptionResource(state: SubscriptionState.None, data: null),
        _auth = FirebaseAuth.instance,
        _firestore = Firestore.instance {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);

    PaymentConfiguration.init('pk_test_QzBEY7OA6yAJWkD9tEmTZI9900rEaBIVHK');
    _stripe = Stripe(PaymentConfiguration.instance.publishableKey);
  }

  SubscriptionPlanType _selectedPlanType = SubscriptionPlanType.Standard;
  SubscriptionPlanInterval _selectedPlanInterval = SubscriptionPlanInterval.Month;

  SubscriptionPlanTheme _planTheme = SubscriptionPlanTheme(SubscriptionPlanType.Standard);

  SubscriptionPlanTheme get planTheme => _planTheme;
  SubscriptionPlanType get selectedPlanType => _selectedPlanType;
  SubscriptionPlanInterval get selectedPlanInterval => _selectedPlanInterval;

  SubscriptionResource _subscription;
  SubscriptionResource get subscription => _subscription;

  FirebaseAuth _auth;
  Firestore _firestore;

  Stripe _stripe;

  StreamSubscription<FirebaseUser> _authSubscription;
  StreamSubscription<DocumentSnapshot> _userDataSubscription;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
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

  Future<void> beginCustomerSession() async {
    await CustomerSession.initCustomerSessionUsingFunction(
        (String apiVersion, EphemeralKeyUpdateListener keyUpdateListener) async {
      print('SubscriptionRepository 2');

      try {
        var rawKey = await Server.createEphemeralKey(
          apiVersion: apiVersion,
        );

        print(rawKey);

        keyUpdateListener.onKeyUpdate(rawKey);
      } catch (e) {
        keyUpdateListener.onKeyUpdateFailure(0, "Ephemeral key creation failed.");
        throw e;
      }
    });
  }

  Future<void> endCustomerSession() async {
    await CustomerSession.endCustomerSession();
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
