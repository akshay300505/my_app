import 'package:flutter/material.dart';

class AcademicDashboardPage extends StatelessWidget {
  const AcademicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        title: const Text("Academic Dashboard"),
      ),
      body: const Center(
        child: Text(
          "Academic Progress Overview",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}