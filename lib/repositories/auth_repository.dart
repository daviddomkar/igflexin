import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:igflexin/resources/auth_info.dart';

class AuthRepository with ChangeNotifier {
  AuthRepository() : _auth = FirebaseAuth.instance {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  FirebaseAuth _auth;
  AuthInfoResource _info;
  StreamSubscription<FirebaseUser> _authSubscription;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _info = AuthInfoResource(state: AuthInfoState.None, data: null);
    } else {
      _info = AuthInfoResource(state: AuthInfoState.Success, data: null);
    }
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _info = AuthInfoResource(state: AuthInfoState.Pending, data: null);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      if (error is PlatformException) {
        print(error.code);
      } else {
        print(error);
        _info = AuthInfoResource(state: AuthInfoState.Error, data: null);
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  AuthInfoResource get info => _info;
}
