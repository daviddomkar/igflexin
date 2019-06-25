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

  Future<void> logInWithEmailAndPassword(String email, String password) async {
    _info = AuthInfoResource(state: AuthInfoState.Pending, data: null);
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      _handleAuthError(error);
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    _info = AuthInfoResource(state: AuthInfoState.Pending, data: null);
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      _handleAuthError(error);
    }
  }

  Future<void> logInWithGoogle() async {
    _info = AuthInfoResource(state: AuthInfoState.Pending, data: null);
    notifyListeners();

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
        notifyListeners();
      }
    } catch (error) {
      _handleAuthError(error);
    }
  }

  Future<void> logInWithFacebook() async {
    _info = AuthInfoResource(state: AuthInfoState.Pending, data: null);
    notifyListeners();

    try {
      var facebookLogin = FacebookLogin();
      var result = await facebookLogin.logInWithReadPermissions(['email', 'public_profile']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          await _auth.signInWithCredential(FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token,
          ));
          break;
        case FacebookLoginStatus.cancelledByUser:
          _info = AuthInfoResource(state: AuthInfoState.None, data: null);
          notifyListeners();
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

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _info = AuthInfoResource(state: AuthInfoState.None, data: null);
    } else {
      _info = AuthInfoResource(state: AuthInfoState.Success, data: null);
    }
    notifyListeners();
  }

  void _handleAuthError(error) {
    AuthError authError = AuthError.Unknown;

    if (error is PlatformException) {
      switch (error.code) {
        case "ERROR_UNKNOWN":
          authError = AuthError.Unknown;
          break;
        case "ERROR_API_NOT_AVAILABLE":
          authError = AuthError.ServiceNotAvailable;
          break;
        case "ERROR_CUSTOM_TOKEN_MISMATCH":
          authError = AuthError.Internal;
          break;
        case "ERROR_USER_DISABLED":
          authError = AuthError.AccountDisabled;
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          authError = AuthError.OperationNotAllowed;
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          authError = AuthError.EmailAlreadyInUse;
          break;
        case "ERROR_INVALID_EMAIL":
          authError = AuthError.InvalidEmail;
          break;
        case "ERROR_WRONG_PASSWORD":
          authError = AuthError.WrongPassword;
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          authError = AuthError.TooManyRequests;
          break;
        case "ERROR_USER_NOT_FOUND":
          authError = AuthError.UserNotFound;
          break;
        case "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL":
          authError = AuthError.AccountExistsWithDifferentCredential;
          break;
        case "ERROR_NETWORK_REQUEST_FAILED":
          authError = AuthError.NetworkError;
          break;
        default:
          authError = AuthError.Unknown;
          break;
      }
    } else if (error is FacebookLoginResult) {
      print(error.errorMessage);
    } else {
      print(error);
    }
    _info = AuthInfoResource(
      state: AuthInfoState.Error,
      data: authError,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  AuthInfoResource get info => _info;

  static String getAuthErrorMessage(AuthError error) {
    switch (error) {
      case AuthError.Unknown:
        return "An unknown error occurred!";
        break;
      case AuthError.ServiceNotAvailable:
        return "Service is not available!";
        break;
      case AuthError.Internal:
        return "Internal server error!";
        break;
      case AuthError.AccountDisabled:
        return "Your account is disabled!";
        break;
      case AuthError.OperationNotAllowed:
        return "This operation is not allowed!";
        break;
      case AuthError.EmailAlreadyInUse:
        return "This email is already in use!";
        break;
      case AuthError.InvalidEmail:
        return "Email is invalid. Check if you typed it correctly!";
        break;
      case AuthError.WrongPassword:
        return "Wrong password!";
        break;
      case AuthError.TooManyRequests:
        return "You are making too many requests!";
        break;
      case AuthError.UserNotFound:
        return "Account with this email adress does not exist!";
        break;
      case AuthError.AccountExistsWithDifferentCredential:
        return "This account is signed up with different login provider! Choose the right login provider and try again!";
        break;
      case AuthError.NetworkError:
        return "Check your internet connection!";
        break;
      default:
        return "An unknown error occurred!";
        break;
    }
  }
}
