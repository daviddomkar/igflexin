import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      }
      _info = AuthInfoResource(state: AuthInfoState.Error, data: null);
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _info = AuthInfoResource(state: AuthInfoState.Pending, data: null);

    try {
      var googleSignIn = GoogleSignIn();
      var account = await googleSignIn.signIn();

      if (account != null) {
        var authentication = await account.authentication;

        await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
          accessToken: authentication.accessToken,
          idToken: authentication.idToken,
        ));
      } else {
        _info = AuthInfoResource(state: AuthInfoState.None, data: null);
      }
    } catch (error) {
      _handleAuthError(error);
    }
  }

  Future<void> signInWithFacebook() async {
    _info = AuthInfoResource(state: AuthInfoState.Pending, data: null);
    try {
      var facebookLogin = FacebookLogin();
      var result = await facebookLogin
          .logInWithReadPermissions(['email', 'public_profile']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          await _auth.signInWithCredential(FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token,
          ));
          break;
        case FacebookLoginStatus.cancelledByUser:
          _info = AuthInfoResource(state: AuthInfoState.None, data: null);
          break;
        case FacebookLoginStatus.error:
          _handleAuthError(result);
          break;
      }
    } catch (error) {
      _handleAuthError(error);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _handleAuthError(error) {
    if (error is PlatformException) {
      print(error.code);
    } else if (error is FacebookLoginResult) {
      print(error.errorMessage);
    } else {
      print(error);
    }
    // TODO Provide error data for better information about the error
    _info = AuthInfoResource(state: AuthInfoState.Error, data: null);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  AuthInfoResource get info => _info;
}
