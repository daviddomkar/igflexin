import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:igflexin/resources/accounts.dart';

class InstagramRepository with ChangeNotifier {
  InstagramRepository()
      : _auth = FirebaseAuth.instance,
        _firestore = Firestore.instance {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  AccountsResource _accounts;
  AccountsResource get accounts => _accounts;

  FirebaseAuth _auth;
  Firestore _firestore;

  StreamSubscription<FirebaseUser> _authSubscription;
  StreamSubscription<QuerySnapshot> _accountsSubscription;

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _accounts = AccountsResource(state: AccountsState.None, data: null);
      if (_accountsSubscription != null) {
        _accountsSubscription.cancel();
      }
      notifyListeners();
    } else {
      _accountsSubscription = _firestore
          .collection('users')
          .document(firebaseUser.uid)
          .collection('accounts')
          .snapshots()
          .listen(_onAccountsChanged);
    }
  }

  Future<void> _onAccountsChanged(QuerySnapshot snapshot) async {
    _accounts = AccountsResource(
        state: AccountsState.Some,
        data: snapshot.documents.map<InstagramAccount>((document) {
          return InstagramAccount(
            username: document.data['username'],
            paused: document.data['paused'],
            status: document.data['status'],
            profilePictureURL: document.data['profilePictureURL'],
          );
        }).toList());
    notifyListeners();
  }

  @override
  void dispose() {
    if (_accountsSubscription != null) {
      _accountsSubscription.cancel();
    }

    _authSubscription.cancel();
    super.dispose();
  }
}
