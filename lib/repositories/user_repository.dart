import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:igflexin/core/server.dart';

import 'package:igflexin/resources/user.dart';

class UserRepository with ChangeNotifier {
  UserRepository()
      : _user = UserResource(state: UserState.None, data: null),
        _auth = FirebaseAuth.instance,
        _firestore = Firestore.instance {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  FirebaseUser _firebaseUser;

  UserResource _user;
  UserResource get user => _user;

  FirebaseAuth _auth;
  Firestore _firestore;

  StreamSubscription<FirebaseUser> _authSubscription;
  StreamSubscription<DocumentSnapshot> _userDataSubscription;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      if (_userDataSubscription != null) {
        _userDataSubscription.cancel();
      }
      _user = UserResource(state: UserState.Unauthenticated, data: null);
      notifyListeners();
    } else {
      _firebaseUser = firebaseUser;
      _userDataSubscription = _firestore
          .collection('users')
          .document(firebaseUser.uid)
          .snapshots()
          .listen(_onUserDataChanged);
    }
  }

  Future<void> _onUserDataChanged(DocumentSnapshot data) async {
    if (data.exists &&
        data.data.containsKey('userCompleted') &&
        data.data['userCompleted'] as bool) {
      _user = UserResource(
          state: UserState.Authenticated,
          data: User(
            email: _firebaseUser.email,
            eligibleForFreeTrial: data.data['eligibleForFreeTrial'],
            userCompleted: data.data['userCompleted'],
          ));
      notifyListeners();
    } else {
      Server.createUserData();
    }
  }

  @override
  void dispose() {
    if (_userDataSubscription != null) {
      _userDataSubscription.cancel();
    }

    _authSubscription.cancel();
    super.dispose();
  }
}
