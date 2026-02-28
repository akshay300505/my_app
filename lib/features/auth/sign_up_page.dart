import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import 'widgets/auth_background.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  final _emailForm = GlobalKey<FormState>();
  final _phoneForm = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  final phoneController = TextEditingController(text: '+91');
  final otpController = TextEditingController();

  bool _showPass = false;
  bool _showConfirm = false;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    emailController.dispose();
    passController.dispose();
    confirmController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: AuthBackground(
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.blur_on, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    "Thrive360",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Create Account",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Start your stress-free journey",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.70)),
                ),
              ),
              const SizedBox(height: 16),

              TabBar(
                controller: _tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
                indicatorColor: const Color(0xFF3EE6C5),
                tabs: const [
                  Tab(text: 'Email'),
                  Tab(text: 'Mobile'),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 360,
                child: TabBarView(
                  controller: _tab,
                  children: [
                    // ✅ EMAIL SIGN UP
                    Form(
                      key: _emailForm,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: emailController,
                            hintText: 'Email (@gmail.com)',
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.gmail,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: passController,
                            hintText: 'New Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !_showPass,
                            validator: Validators.password,
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _showPass = !_showPass),
                              icon: Icon(
                                _showPass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: confirmController,
                            hintText: 'Confirm Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !_showConfirm,
                            validator: (v) =>
                                Validators.confirmPassword(v, passController.text),
                            suffix: IconButton(
                              onPressed: () => setState(
                                  () => _showConfirm = !_showConfirm),
                              icon: Icon(
                                _showConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Sign Up',
                            loading: auth.loading,
                            onPressed: () async {
                              if (!_emailForm.currentState!.validate()) return;
                              try {
                                await auth.signUpWithEmail(
                                  emailController.text.trim(),
                                  passController.text.trim(),
                                );
                                _snack(
                                    "Verification mail sent. Please verify your Gmail.");
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              } catch (e) {
                                _snack(e.toString());
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // ✅ MOBILE SIGN UP (OTP)
                    Form(
                      key: _phoneForm,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: phoneController,
                            hintText: 'Mobile (+91XXXXXXXXXX)',
                            prefixIcon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                          ),
                          const SizedBox(height: 12),
                          if (_otpSent)
                            CustomTextField(
                              controller: otpController,
                              hintText: 'Enter OTP',
                              prefixIcon: Icons.sms_outlined,
                              keyboardType: TextInputType.number,
                              validator: Validators.otp,
                            ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: _otpSent ? 'Verify OTP' : 'Send OTP',
                            loading: auth.loading,
                            onPressed: () async {
                              if (!_phoneForm.currentState!.validate()) return;
                              try {
                                if (!_otpSent) {
                                  await auth.sendOtp(
                                    phoneNumber: phoneController.text.trim(),
                                    onCodeSent: () {
                                      setState(() => _otpSent = true);
                                      _snack("OTP sent");
                                    },
                                    onError: (m) => _snack(m),
                                  );
                                } else {
                                  await auth.verifyOtpAndLogin(
                                      otpController.text.trim());
                                }
                              } catch (e) {
                                _snack(e.toString());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75))),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Login"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}