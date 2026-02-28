import 'package:flutter/material.dart';

import '../../features/auth/auth_wrapper.dart';
import '../../features/auth/sign_in_page.dart';
import '../../features/auth/sign_up_page.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/dashboard/dashboard_page.dart';

class AppRouter {
  // Route Names (centralized)
  static const String root = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case root:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const SignInPage(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("Page not found"),
            ),
          ),
        );
    }
  }
}