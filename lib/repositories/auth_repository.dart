import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository with ChangeNotifier {
  AuthRepository();

  FirebaseAuth _auth;
  FirebaseUser _user;
}
