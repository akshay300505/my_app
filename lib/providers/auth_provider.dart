import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --------------------------
  // Loading
  // --------------------------
  bool _loading = false;
  bool get isLoading => _loading;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // --------------------------
  // OTP UI State
  // --------------------------
  bool _otpFieldVisible = false;
  bool get otpFieldVisible => _otpFieldVisible;

  // Android verification
  String? _verificationId;
  int? _forceResendToken;

  // Web confirmation
  ConfirmationResult? _webConfirmation;

  // Resend timer
  int _resendSecondsLeft = 0;
  int get resendSecondsLeft => _resendSecondsLeft;

  Timer? _timer;

  void showOtpField() {
    _otpFieldVisible = true;
    notifyListeners();
  }

  void resetOtpUi() {
    _verificationId = null;
    _forceResendToken = null;
    _webConfirmation = null;

    _otpFieldVisible = false;

    _timer?.cancel();
    _timer = null;
    _resendSecondsLeft = 0;

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

  /// Returns null on success, or an error message on failure.
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Refresh user state
      await cred.user?.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (_) {
      return "Something went wrong. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up + send verification email (ONLY on signup).
  /// Returns null on success, or an error message on failure.
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user;
      if (user == null) {
        return "Account creation failed. Please try again.";
      }

      // ✅ secure Firebase-managed verification email
      await user.sendEmailVerification();
      await user.reload();

      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (_) {
      return "Something went wrong. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  /// Used by SignInPage to decide if it should route to VerifyEmailPage.
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Verify email screen: resend verification email
  Future<String?> resendVerificationEmail() async {
    try {
      _setLoading(true);

      final user = _auth.currentUser;
      if (user == null) return "No user signed in.";

      await user.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (_) {
      return "Something went wrong. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  /// Forgot password (must send to exact email)
  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (_) {
      return "Something went wrong. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    resetOtpUi();
  }

  // --------------------------
  // Phone OTP (Android + Web)
  // --------------------------

  /// Returns null on success, or an error message on failure.
  ///
  /// NOTE (Web):
  /// Firebase automatically uses reCAPTCHA. Ensure your web/index.html contains:
  /// <div id="recaptcha-container"></div>
  Future<String?> sendOtp({
    required String phoneNumber,
    bool forceResend = false,
  }) async {
    try {
      _setLoading(true);

      // show OTP field should be done by UI instantly (SignInPage calls showOtpField()).
      // but if someone calls sendOtp directly, we still ensure:
      _otpFieldVisible = true;
      notifyListeners();

      final number = phoneNumber.trim();

      if (kIsWeb) {
        // Web: triggers reCAPTCHA internally
        _webConfirmation = await _auth.signInWithPhoneNumber(number);
        _startResendTimer(seconds: 60);
        return null;
      }

      // Android/iOS
      await _auth.verifyPhoneNumber(
        phoneNumber: number,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResend ? _forceResendToken : null,

        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android may auto-verify
          await _auth.signInWithCredential(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          throw e;
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

      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (_) {
      return "Something went wrong. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> verifyOtp({required String otp}) async {
    try {
      _setLoading(true);

      final code = otp.trim();

      if (kIsWeb) {
        final conf = _webConfirmation;
        if (conf == null) return "Please send OTP first.";
        await conf.confirm(code);
        return null;
      }

      final vid = _verificationId;
      if (vid == null) return "Please send OTP first.";

      final cred = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: code,
      );

      await _auth.signInWithCredential(cred);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } catch (_) {
      return "Something went wrong. Please try again.";
    } finally {
      _setLoading(false);
    }
  }

  /// Optional: resend OTP (only when timer ends)
  Future<String?> resendOtp({required String phoneNumber}) async {
    if (_resendSecondsLeft > 0) {
      return "Please wait $_resendSecondsLeft seconds to resend.";
    }
    return sendOtp(phoneNumber: phoneNumber, forceResend: true);
  }

  // --------------------------
  // Friendly errors
  // --------------------------
  String _friendlyAuthError(FirebaseAuthException e) {
    final code = e.code.toLowerCase();

    if (code == 'invalid-email') return 'Invalid email address.';
    if (code == 'user-not-found') return 'No account found for that email.';
    if (code == 'wrong-password') return 'Incorrect password.';
    if (code == 'email-already-in-use') return 'Email is already registered.';
    if (code == 'weak-password') return 'Password is too weak (min 6 characters).';
    if (code == 'too-many-requests') return 'Too many attempts. Try again later.';

    // Phone OTP errors
    if (code == 'invalid-verification-code') return 'Invalid OTP. Please try again.';
    if (code == 'session-expired') return 'OTP expired. Please resend OTP.';
    if (code == 'invalid-phone-number') return 'Invalid phone number. Use +91XXXXXXXXXX.';
    if (code == 'quota-exceeded') return 'SMS quota exceeded. Try again later.';

    // Web reCAPTCHA / domain issues sometimes appear like this:
    if (e.message != null && e.message!.trim().isNotEmpty) return e.message!.trim();

    return 'Authentication failed. Please try again.';
  }
}