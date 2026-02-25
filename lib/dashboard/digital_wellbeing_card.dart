import 'package:flutter/material.dart';
import 'digital_wellbeing_page.dart';

class DigitalWellbeingCard extends StatelessWidget {
  const DigitalWellbeingCard({super.key});

  static const Color lavender = Color(0xFFEDE7F6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DigitalWellbeingPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lavender,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          children: [
            Icon(Icons.health_and_safety, size: 40),
            SizedBox(height: 10),
            Text(
              "Digital Wellbeing",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}