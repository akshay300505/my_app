import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _loading = false;
  bool get isLoading => _loading;

  // OTP state
  bool _otpFieldVisible = false;
  bool get otpFieldVisible => _otpFieldVisible;

  String? _verificationId; // Android
  int? _forceResendToken; // Android
  ConfirmationResult? _webConfirmation; // Web

  int _resendSecondsLeft = 0;
  int get resendSecondsLeft => _resendSecondsLeft;

  Timer? _timer;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _showOtpField(bool v) {
    _otpFieldVisible = v;
    notifyListeners();
  }

  void _startResendTimer({int seconds = 60}) {
    _timer?.cancel();
    _resendSecondsLeft = seconds;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _resendSecondsLeft--;
      if (_resendSecondsLeft <= 0) {
        _resendSecondsLeft = 0;
        t.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --------------------------
  // Email Auth
  // --------------------------

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.reload();
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user;
      if (user == null) throw Exception('User creation failed');

      await user.sendEmailVerification();
      await user.reload();

      // Force strict flow: verify email then sign in
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  // --------------------------
  // Phone OTP (works for Sign In + Sign Up)
  // --------------------------

  /// Matches your SignUpPage call:
  /// await auth.sendOtp(phoneNumber: _phoneC.text.trim());
  Future<void> sendOtp({
    required String phoneNumber,
    bool forceResend = false,
  }) async {
    _setLoading(true);

    // Show OTP field immediately (your requirement)
    _showOtpField(true);

    try {
      if (kIsWeb) {
        _webConfirmation = await _auth.signInWithPhoneNumber(phoneNumber);
        _startResendTimer(seconds: 60);
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResend ? _forceResendToken : null,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval (Android) if possible
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(_friendlyAuthError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _forceResendToken = resendToken;
          _startResendTimer(seconds: 60);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    _setLoading(true);
    try {
      if (kIsWeb) {
        final conf = _webConfirmation;
        if (conf == null) throw Exception('Please send OTP first.');
        await conf.confirm(otp);
        return;
      }

      final vid = _verificationId;
      if (vid == null) throw Exception('Please send OTP first.');

      final cred = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: otp,
      );
      await _auth.signInWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOtp({required String phoneNumber}) async {
    if (_resendSecondsLeft > 0) return;
    await sendOtp(phoneNumber: phoneNumber, forceResend: true);
  }

  void resetOtpUi() {
    _verificationId = null;
    _webConfirmation = null;
    _showOtpField(false);
    _timer?.cancel();
    _resendSecondsLeft = 0;
    notifyListeners();
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    final code = e.code.toLowerCase();

    if (code.contains('invalid-email')) return 'Invalid email address.';
    if (code.contains('user-not-found')) return 'No account found for that email.';
    if (code.contains('wrong-password')) return 'Incorrect password.';
    if (code.contains('email-already-in-use')) return 'Email is already registered.';
    if (code.contains('weak-password')) return 'Password is too weak.';
    if (code.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    if (code.contains('invalid-verification-code')) return 'Invalid OTP. Please try again.';
    if (code.contains('session-expired')) return 'OTP expired. Please resend OTP.';
    if (code.contains('invalid-phone-number')) return 'Invalid phone number.';
    if (e.message != null && e.message!.trim().isNotEmpty) return e.message!;
    return 'Authentication failed. Please try again.';
  }
}