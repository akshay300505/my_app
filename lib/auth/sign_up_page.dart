
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final identifierCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool isPhone = false;
  bool otpSent = false;
  bool obscure = true;
  bool loading = false;

  int timer = 0;
  Timer? _timer;

  void detectInput(String value) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,13}$');
    setState(() {
      isPhone = phoneRegex.hasMatch(value.trim());
      otpSent = false;
      otpCtrl.clear();
    });
  }

  // 🔐 SIGN UP WITH EMAIL + SAVE TO FIRESTORE
  Future<void> _signUpWithEmail() async {
    if (identifierCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    setState(() => loading = true);

    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: identifierCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final user = credential.user;

      if (user != null) {
        // 🔥 SAVE USER DATA IN FIRESTORE
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // ✅ SUCCESS MESSAGE
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account created successfully 🎉"),
              backgroundColor: Colors.green,
            ),
          );
        }

        // ⏳ SMALL DELAY FOR UX
        await Future.delayed(const Duration(seconds: 1));

        // 🚀 GO TO DASHBOARD
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Signup failed');
    } catch (_) {
      _showMessage('Something went wrong');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void startTimer() {
    timer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
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
    _timer?.cancel();
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
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/signin'),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _activeTab("Sign Up"),
                ],
              ),

              const SizedBox(height: 24),

              _inputField(
                "Email or Phone",
                identifierCtrl,
                onChanged: detectInput,
              ),

              const SizedBox(height: 16),

              if (!isPhone)
                _passwordField()
              else if (otpSent)
                _otpField(),

              const SizedBox(height: 24),

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
                              startTimer();
                            }
                          } else {
                            _signUpWithEmail(); // 🔥 MAIN FIX
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          isPhone
                              ? (otpSent ? "Verify OTP" : "Send OTP")
                              : "Create Account",
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