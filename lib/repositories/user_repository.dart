import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:igflexin/resources/user.dart';

class UserRepository with ChangeNotifier {
  UserRepository()
      : _user = UserResource(state: UserState.None, data: null),
        _auth = FirebaseAuth.instance {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  UserResource _user;
  FirebaseAuth _auth;
  StreamSubscription<FirebaseUser> _authSubscription;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _user = UserResource(state: UserState.Unauthenticated, data: null);
    } else {
      _user = UserResource(state: UserState.Authenticated, data: null);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  UserResource get user => _user;
}
