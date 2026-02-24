import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          width: width < 600 ? width * 0.9 : 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Mind Care",
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              _authButton(
                text: "Sign In",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                ),
              ),

              const SizedBox(height: 20),

              _authButton(
                text: "Sign Up",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _authButton({required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF38BDF8),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
