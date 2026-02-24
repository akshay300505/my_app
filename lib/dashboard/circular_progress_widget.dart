import 'package:flutter/material.dart';

class CircularProgressWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final Color color;
  final double size;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.label,
    this.color = Colors.blue,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: Colors.white24,
                strokeWidth: 8,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white60),
        ),
      ],
    );
  }
}