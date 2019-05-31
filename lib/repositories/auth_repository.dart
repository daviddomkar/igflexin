import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:igflexin/resources/user.dart';

class AuthRepository with ChangeNotifier {
  AuthRepository()
      : _user = UserResource(state: UserState.None, data: null),
        _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  UserResource _user;
  FirebaseAuth _auth;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _user = UserResource(state: UserState.Unauthenticated, data: null);
    } else {
      _user = UserResource(state: UserState.Authenticated, data: null);
    }
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  UserResource get user => _user;
}
