import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:igflexin/core/server.dart';
import 'package:igflexin/model/instagram_response.dart';
import 'package:igflexin/resources/accounts.dart';

class InstagramRepository with ChangeNotifier {
  InstagramRepository()
      : _auth = FirebaseAuth.instance,
        _firestore = Firestore.instance {
    _authSubscription = _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  AccountsResource _accounts;
  AccountsResource get accounts => _accounts;

  InstagramAccount _selectedAccount;
  InstagramAccount get selectedAccount => _selectedAccount;

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
    if (snapshot.documents.length > 1) {
      _selectedAccount = InstagramAccount(
        id: snapshot.documents[0].documentID,
        username: snapshot.documents[0].data['username'],
        paused: snapshot.documents[0].data['paused'],
        status: snapshot.documents[0].data['status'],
        profilePictureURL: snapshot.documents[0].data['profilePictureURL'],
      );
    }

    _accounts = AccountsResource(
        state: AccountsState.Some,
        data: snapshot.documents.map<InstagramAccount>((document) {
          return InstagramAccount(
            id: document.documentID,
            username: document.data['username'],
            paused: document.data['paused'],
            status: document.data['status'],
            profilePictureURL: document.data['profilePictureURL'],
          );
        }).toList());
    notifyListeners();
  }

  void selectAccount({
    String id,
  }) {
    _selectedAccount = _accounts.data.firstWhere((account) => account.id == id);
    notifyListeners();
  }

  Future<void> pause({
    String id,
  }) async {
    await _firestore
        .collection('users')
        .document((await _auth.currentUser()).uid)
        .collection('accounts')
        .document(id)
        .updateData(<String, dynamic>{
      'paused': true,
    });
  }

  Future<void> resume({
    String id,
  }) async {
    await _firestore
        .collection('users')
        .document((await _auth.currentUser()).uid)
        .collection('accounts')
        .document(id)
        .updateData(<String, dynamic>{
      'paused': false,
    });
  }

  Future<void> delete({
    String id,
  }) async {
    await _firestore
        .collection('users')
        .document((await _auth.currentUser()).uid)
        .collection('accounts')
        .document(id)
        .delete();
  }

  Future<InstagramResponse> addInstagramAccount({
    String username,
    String password,
  }) async {
    return await Server.addAccount(
      username: username,
      password: password,
    );
  }

  Future<InstagramResponse> editInstagramAccount({
    String username,
    String password,
    String id,
  }) async {
    return await Server.editAccount(
      username: username,
      password: password,
      id: id,
    );
  }

  Future<InstagramResponse> sendSecurityCode({
    String username,
    String securityCode,
  }) async {
    return await Server.sendSecurityCode(
      username: username,
      securityCode: securityCode,
    );
  }

  Future<InstagramResponse> sendTwoFactorAuthCode({
    String username,
    String securityCode,
  }) async {
    return await Server.sendTwoFactorAuthCode(
      username: username,
      securityCode: securityCode,
    );
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
