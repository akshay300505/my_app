import 'package:flutter/material.dart';

class CircularWellbeingWidget extends StatelessWidget {
  final double progress;
  final String timeText;

  const CircularWellbeingWidget({
    super.key,
    required this.progress,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 14,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(
              Color(0xFF4FC3F7),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeText,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Today",
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ],
    );
  }
}