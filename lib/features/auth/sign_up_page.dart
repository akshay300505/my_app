import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';

enum SignUpMode { email, phone }

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPhone = GlobalKey<FormState>();

  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  final _phoneC = TextEditingController(text: '+91');
  final _otpC = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;
  SignUpMode _mode = SignUpMode.email;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    _phoneC.dispose();
    _otpC.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _emailSignUp(AuthProvider auth) async {
    if (!_formKeyEmail.currentState!.validate()) return;

    try {
      await auth.signUpWithEmail(
        email: _emailC.text.trim(),
        password: _passC.text.trim(),
      );

      _snack(
        "Account created. Verification email sent. Please verify and then sign in.",
      );

      if (!mounted) return;
      Navigator.pop(context); // Go back to Sign In
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _phoneSendOtp(AuthProvider auth) async {
    if (!_formKeyPhone.currentState!.validate()) return;

    try {
      await auth.sendOtp(phoneNumber: _phoneC.text.trim());
      _snack("OTP sent.");
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _phoneVerifyOtp(AuthProvider auth) async {
    final otpErr = Validators.otp6(_otpC.text);
    if (otpErr != null) {
      _snack(otpErr);
      return;
    }

    try {
      await auth.verifyOtp(otp: _otpC.text.trim());
      _snack("Phone sign-up success.");
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const _AuthBackground(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// MODE TOGGLE
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setState(() => _mode = SignUpMode.email);
                                  auth.resetOtpUi();
                                },
                                child: const Text("Email"),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setState(() => _mode = SignUpMode.phone);
                                  auth.resetOtpUi();
                                },
                                child: const Text("Mobile OTP"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        if (_mode == SignUpMode.email)
                          Form(
                            key: _formKeyEmail,
                            child: Column(
                              children: [
                                _Input(
                                  label: 'Email (gmail only)',
                                  controller: _emailC,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.gmailOnly,
                                ),
                                const SizedBox(height: 12),
                                _Input(
                                  label: 'Password',
                                  controller: _passC,
                                  obscure: _hidePass,
                                  validator: Validators.password,
                                  suffix: IconButton(
                                    onPressed: () => setState(() =>
                                        _hidePass = !_hidePass),
                                    icon: Icon(
                                      _hidePass
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color:
                                          Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _Input(
                                  label: 'Confirm Password',
                                  controller: _confirmC,
                                  obscure: _hideConfirm,
                                  validator: (v) => Validators
                                      .confirmPassword(
                                          v, _passC.text),
                                  suffix: IconButton(
                                    onPressed: () => setState(() =>
                                        _hideConfirm = !_hideConfirm),
                                    icon: Icon(
                                      _hideConfirm
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color:
                                          Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () => _emailSignUp(auth),
                                  child: auth.isLoading
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2)
                                      : const Text('Create Account'),
                                ),
                              ],
                            ),
                          )
                        else
                          Form(
                            key: _formKeyPhone,
                            child: Column(
                              children: [
                                _Input(
                                  label:
                                      'Mobile Number (+91XXXXXXXXXX)',
                                  controller: _phoneC,
                                  keyboardType:
                                      TextInputType.phone,
                                  validator: Validators.phone,
                                ),
                                const SizedBox(height: 12),

                                if (auth.otpFieldVisible)
                                  _Input(
                                    label: 'Enter 6-digit OTP',
                                    controller: _otpC,
                                    keyboardType:
                                        TextInputType.number,
                                    validator: Validators.otp6,
                                    maxLength: 6,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                          6),
                                    ],
                                  ),

                                const SizedBox(height: 14),

                                FilledButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                          if (!auth.otpFieldVisible) {
                                            _phoneSendOtp(auth);
                                          } else {
                                            _phoneVerifyOtp(auth);
                                          }
                                        },
                                  child: auth.isLoading
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2)
                                      : Text(auth.otpFieldVisible
                                          ? "Verify OTP"
                                          : "Send OTP"),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 14),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child:
                              const Text("Back to Sign In"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// UI Components (Unchanged)
class _Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _Input({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(28),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0B2E), Color(0xFF2A0A5E)],
        ),
      ),
    );
  }
}