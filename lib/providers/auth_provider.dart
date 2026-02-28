import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthProvider extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  // Android/iOS OTP
  String? _verificationId;
  int? _resendToken;

  // Web OTP
  fb.ConfirmationResult? _webConfirmation;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // ✅ EMAIL SIGN IN
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    } finally {
      _setLoading(false);
    }
  }

  // ✅ EMAIL SIGN UP + SEND VERIFICATION MAIL
  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user?.sendEmailVerification(); // ✅ sends mail
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Signup failed");
    } finally {
      _setLoading(false);
    }
  }

  // ✅ SEND OTP (Web + Mobile)
  Future<void> sendOtp({
    required String phoneNumber,
    required VoidCallback onCodeSent,
    required void Function(String message) onError,
  }) async {
    _setLoading(true);
    try {
      if (kIsWeb) {
        _webConfirmation = await _auth.signInWithPhoneNumber(phoneNumber);
        onCodeSent();
        return;
      }

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
    } catch (e) {
      onError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ✅ VERIFY OTP
  Future<void> verifyOtpAndLogin(String smsCode) async {
    _setLoading(true);
    try {
      if (kIsWeb) {
        if (_webConfirmation == null) throw Exception("OTP not requested yet");
        await _webConfirmation!.confirm(smsCode);
        return;
      }

      if (_verificationId == null) throw Exception("OTP not requested yet");

      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "OTP verification failed");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}