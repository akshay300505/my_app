import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthProvider extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  // ✅ Fix for AuthWrapper stream
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}