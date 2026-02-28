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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          _AuthBackground(), // ✅ NOT const (because withOpacity() is non-const)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(22),
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

                      _ModeToggle(
                        value: _mode,
                        onChanged: (v) {
                          setState(() => _mode = v);
                          auth.resetOtpUi();
                          _otpC.clear();
                        },
                      ),
                      const SizedBox(height: 14),

                      if (_mode == SignUpMode.email) ...[
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
                                  onPressed: () => setState(() => _hidePass = !_hidePass),
                                  icon: Icon(
                                    _hidePass ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _Input(
                                label: 'Confirm Password',
                                controller: _confirmC,
                                obscure: _hideConfirm,
                                validator: (v) => Validators.confirmPassword(v, _passC.text),
                                suffix: IconButton(
                                  onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                                  icon: Icon(
                                    _hideConfirm ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () async {
                                          if (!_formKeyEmail.currentState!.validate()) return;
                                          try {
                                            await auth.signUpWithEmail(
                                              email: _emailC.text.trim(),
                                              password: _passC.text.trim(),
                                            );
                                            _snack(
                                              'Account created. Verification email sent. Please verify, then sign in.',
                                            );
                                            if (!mounted) return;
                                            Navigator.pop(context);
                                          } catch (e) {
                                            _snack(e.toString().replaceFirst('Exception: ', ''));
                                          }
                                        },
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Create Account'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Form(
                          key: _formKeyPhone,
                          child: Column(
                            children: [
                              _Input(
                                label: 'Mobile Number (e.g. +91XXXXXXXXXX)',
                                controller: _phoneC,
                                keyboardType: TextInputType.phone,
                                validator: Validators.phone,
                              ),
                              const SizedBox(height: 12),

                              if (auth.otpFieldVisible) ...[
                                _Input(
                                  label: 'Enter 6-digit OTP',
                                  controller: _otpC,
                                  keyboardType: TextInputType.number,
                                  validator: Validators.otp6,
                                  maxLength: 6,
                                  // ✅ FIX: remove const here (your main error)
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        auth.resendSecondsLeft > 0
                                            ? 'Resend in ${auth.resendSecondsLeft}s'
                                            : 'Didn’t receive OTP?',
                                        style: TextStyle(color: Colors.white.withOpacity(0.75)),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (auth.resendSecondsLeft > 0 || auth.isLoading)
                                          ? null
                                          : () async {
                                              if (Validators.phone(_phoneC.text) != null) {
                                                _snack('Enter a valid phone number first.');
                                                return;
                                              }
                                              try {
                                                await auth.resendOtp(phoneNumber: _phoneC.text.trim());
                                                _snack('New OTP sent.');
                                              } catch (e) {
                                                _snack(e.toString().replaceFirst('Exception: ', ''));
                                              }
                                            },
                                      child: const Text('Resend OTP'),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () async {
                                          if (!auth.otpFieldVisible) {
                                            if (!_formKeyPhone.currentState!.validate()) return;
                                            try {
                                              await auth.sendOtp(phoneNumber: _phoneC.text.trim());
                                              _snack('OTP sent.');
                                            } catch (e) {
                                              _snack(e.toString().replaceFirst('Exception: ', ''));
                                            }
                                          } else {
                                            final otpErr = Validators.otp6(_otpC.text);
                                            if (otpErr != null) {
                                              _snack(otpErr);
                                              return;
                                            }
                                            try {
                                              await auth.verifyOtp(otp: _otpC.text.trim());
                                              _snack('Phone sign-up success.');
                                              if (!mounted) return;
                                              Navigator.pop(context);
                                            } catch (e) {
                                              _snack(e.toString().replaceFirst('Exception: ', ''));
                                            }
                                          }
                                        },
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text(auth.otpFieldVisible ? 'Verify OTP' : 'Send OTP'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: auth.isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Back to Sign In'),
                      ),
                    ],
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

class _ModeToggle extends StatelessWidget {
  final SignUpMode value;
  final ValueChanged<SignUpMode> onChanged;

  const _ModeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegButton(
              active: value == SignUpMode.email,
              text: 'Email',
              onTap: () => onChanged(SignUpMode.email),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegButton(
              active: value == SignUpMode.phone,
              text: 'Mobile OTP',
              onTap: () => onChanged(SignUpMode.phone),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final bool active;
  final String text;
  final VoidCallback onTap;

  const _SegButton({required this.active, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active ? Colors.white.withOpacity(0.14) : Colors.transparent,
          border: Border.all(color: Colors.white.withOpacity(active ? 0.22 : 0.10)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.92)),
          ),
        ),
      ),
    );
  }
}

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
      cursorColor: Colors.white,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        counterText: '',
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.30)),
        ),
        suffixIcon: suffix,
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
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
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
          colors: [Color(0xFF0B0B2E), Color(0xFF2A0A5E), Color(0xFF0E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: _GlowBlob(
              color: const Color(0xFF8B5CF6).withOpacity(0.55),
              size: 240,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -70,
            child: _GlowBlob(
              color: const Color(0xFF38BDF8).withOpacity(0.45),
              size: 280,
            ),
          ),
          Positioned(
            top: 160,
            right: -90,
            child: _GlowBlob(
              color: const Color(0xFFEC4899).withOpacity(0.35),
              size: 220,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}