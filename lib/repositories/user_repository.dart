import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:igflexin/resources/user.dart';

class UserRepository with ChangeNotifier {
  UserRepository()
      : _user = UserResource(state: UserState.None, data: null),
        _auth = FirebaseAuth.instance,
        _firestore = Firestore.instance,
        _functions = CloudFunctions.instance {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  UserResource _user;
  FirebaseAuth _auth;
  Firestore _firestore;
  CloudFunctions _functions;
  StreamSubscription<FirebaseUser> _authSubscription;
  StreamSubscription<DocumentSnapshot> _userDataSubscription;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _user = UserResource(state: UserState.Unauthenticated, data: null);
    } else {
      _user = UserResource(state: UserState.Authenticated, data: null);
    }

    notifyListeners();
  }

  Future<void> _onUserDataChanged(DocumentSnapshot data) async {
    print('_onUserDataChanged');
    if (data.exists && data.data.containsKey('userCompleted')) {
      _user = UserResource(
          state: UserState.Authenticated,
          data: User(
            eligibleForFreeTrial: data.data['eligibleForFreeTrial'],
            userCompleted: data.data['userCompleted'],
          ));
    } else {
      _functions.getHttpsCallable(functionName: 'createUserData').call();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _userDataSubscription.cancel();
    _authSubscription.cancel();
    super.dispose();
  }

  UserResource get user => _user;
}
