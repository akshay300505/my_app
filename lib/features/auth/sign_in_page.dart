import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'forgot_password_page.dart';
import 'sign_up_page.dart';
import 'widgets/auth_background.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  final _emailForm = GlobalKey<FormState>();
  final _phoneForm = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final phoneController = TextEditingController(text: '+91');
  final otpController = TextEditingController();

  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return;
      context.read<AuthProvider>().resetOtpUi();
      otpController.clear();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _emailLogin(AuthProvider auth) async {
    if (!_emailForm.currentState!.validate()) return;
    try {
      await auth.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _snack("Login success");
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _sendOtp(AuthProvider auth) async {
    if (!_phoneForm.currentState!.validate()) return;
    try {
      await auth.sendOtp(phoneNumber: phoneController.text.trim());
      _snack("OTP sent");
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _verifyOtp(AuthProvider auth) async {
    final err = Validators.otp6(otpController.text);
    if (err != null) {
      _snack(err);
      return;
    }
    try {
      await auth.verifyOtp(otp: otpController.text.trim());
      _snack("Login success");
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
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
                      color: Colors.white.withOpacity(0.95),
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
                  "Welcome Back",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Login to continue your journey",
                  style: TextStyle(color: Colors.white.withOpacity(0.70)),
                ),
              ),
              const SizedBox(height: 16),

              TabBar(
                controller: _tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.65),
                indicatorColor: const Color(0xFF3EE6C5),
                tabs: const [
                  Tab(text: 'Email'),
                  Tab(text: 'Mobile'),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 320,
                child: TabBarView(
                  controller: _tab,
                  children: [
                    Form(
                      key: _emailForm,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: emailController,
                            hintText: 'Email (@gmail.com)',
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.gmailOnly,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !_showPassword,
                            validator: Validators.password,
                            suffix: IconButton(
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                              icon: Icon(
                                _showPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                                      ),
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.white.withOpacity(0.75)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: 'Login',
                            loading: auth.isLoading,
                            onPressed: () => _emailLogin(auth),
                          ),
                        ],
                      ),
                    ),
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
                          if (auth.otpFieldVisible)
                            CustomTextField(
                              controller: otpController,
                              hintText: 'Enter 6-digit OTP',
                              prefixIcon: Icons.sms_outlined,
                              keyboardType: TextInputType.number,
                              validator: Validators.otp6,
                            ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: auth.otpFieldVisible ? 'Verify OTP' : 'Send OTP',
                            loading: auth.isLoading,
                            onPressed: () {
                              if (!auth.otpFieldVisible) {
                                _sendOtp(auth);
                              } else {
                                _verifyOtp(auth);
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
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white.withOpacity(0.75)),
                  ),
                  TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignUpPage()),
                            ),
                    child: const Text("Sign Up"),
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