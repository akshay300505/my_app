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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: lavender,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Digital Wellbeing",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Track screen time across Mobile • Laptop • Tablet",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Tap to View Analytics",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}