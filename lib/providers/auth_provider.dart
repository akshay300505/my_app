import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthProvider extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  String? _verificationId;
  int? _resendToken;

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Send verification mail
      await cred.user?.sendEmailVerification();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required VoidCallback onCodeSent,
    required void Function(String message) onError,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          onError(e.message ?? "Phone verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtpAndLogin(String smsCode) async {
    if (_verificationId == null) throw Exception("OTP not requested yet");
    try {
      _loading = true;
      notifyListeners();

      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}