import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import 'widgets/auth_header.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2F), Color(0xFF1E3C72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthHeader(
                      title: "Create Account",
                      subtitle: "Join Thrive360 today",
                    ),
                    const SizedBox(height: 25),
                    CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      icon: Icons.email_outlined,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 18),
                    CustomButton(
                      text: "Sign Up",
                      loading: authProvider.loading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        try {
                          await authProvider.signUp(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                          // After signup, AuthWrapper will redirect to Dashboard automatically.
                          if (!context.mounted) return;
                          Navigator.pop(context); // optional: go back to sign in UI
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}