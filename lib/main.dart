import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/study_provider.dart';
import 'providers/wellbeing_provider.dart';
import 'providers/time_management_provider.dart';

// ✅ ADD THIS IMPORT
import 'features/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Thrive360App());
}

class Thrive360App extends StatelessWidget {
  const Thrive360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => WellbeingProvider()),
        ChangeNotifierProvider(create: (_) => TimeManagementProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // ✅ unchanged
        home: const AuthWrapper(),  // ✅ THIS shows SignIn/SignUp and Dashboard flow
      ),
    );
  }
}