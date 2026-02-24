
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final identifierCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool isPhone = false;
  bool otpSent = false;
  bool obscure = true;
  bool loading = false;

  int timer = 0;
  Timer? _resendTimer;

  void detectInput(String value) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,13}$');
    setState(() {
      isPhone = phoneRegex.hasMatch(value.trim());
      otpSent = false;
      otpCtrl.clear();
    });
  }

  // 🔐 EMAIL SIGN-IN + FIRESTORE SAVE
  Future<void> _signInWithEmail() async {
    if (identifierCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    setState(() => loading = true);

    try {
      final UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: identifierCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final user = credential.user;

      if (user != null) {
        // 🔥 SAVE / UPDATE USER IN FIRESTORE
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'email': user.email,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 🚀 NAVIGATION
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Login failed');
    } catch (_) {
      _showError('Something went wrong');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void startOtpTimer() {
    timer = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer == 0) {
        t.cancel();
      } else {
        setState(() => timer--);
      }
    });
  }

  @override
  void dispose() {
    identifierCtrl.dispose();
    passwordCtrl.dispose();
    otpCtrl.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white24),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Thrive 360",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4FC3F7),
                ),
              ),

              const SizedBox(height: 20),

              /// TOGGLE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _activeTab("Sign In"),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// EMAIL / PHONE
              _inputField(
                "Email or Phone",
                identifierCtrl,
                onChanged: detectInput,
              ),

              const SizedBox(height: 16),

              /// PASSWORD / OTP
              if (!isPhone)
                _passwordField()
              else if (otpSent)
                _otpField(),

              if (isPhone && otpSent) const SizedBox(height: 10),

              if (isPhone && otpSent && timer > 0)
                Text(
                  "Resend OTP in $timer s",
                  style: const TextStyle(color: Colors.white54),
                ),

              const SizedBox(height: 24),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (isPhone) {
                            if (!otpSent) {
                              setState(() => otpSent = true);
                              startOtpTimer();
                            }
                          } else {
                            _signInWithEmail();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : Text(
                          isPhone
                              ? (otpSent ? "Verify OTP" : "Send OTP")
                              : "Sign In",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4FC3F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600)),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: passwordCtrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white54,
          ),
          onPressed: () => setState(() => obscure = !obscure),
        ),
      ),
    );
  }

  Widget _otpField() {
    return TextField(
      controller: otpCtrl,
      maxLength: 6,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        letterSpacing: 22,
        fontSize: 18,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        counterText: "",
        hintText: "------",
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _inputField(
    String hint,
    TextEditingController ctrl, {
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}