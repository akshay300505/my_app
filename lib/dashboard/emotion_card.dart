import 'package:flutter/material.dart';

class EmotionCard extends StatelessWidget {
  const EmotionCard({super.key});

  static const Color softBlue = Color(0xFFD8EAFB);
  static const Color mintGreen = Color(0xFFDFF5E3);
  static const Color lightCream = Color(0xFFF7F9F9);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: mintGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            "Emotional Space",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Hello, how are you feeling today?",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 16),

          // Emotion Buttons
          Row(
            children: const [
              _EmotionChip(label: "😊 Calm", color: Colors.green),
              SizedBox(width: 8),
              _EmotionChip(label: "😐 Okay", color: Colors.orange),
              SizedBox(width: 8),
              _EmotionChip(label: "😟 Stressed", color: Colors.redAccent),
            ],
          ),

          const SizedBox(height: 16),

          // Input Field
          Container(
            decoration: BoxDecoration(
              color: lightCream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write what's on your mind...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              _ActionButton(
                text: "I hear you",
                color: softBlue,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                text: "That's tough",
                color: Colors.orange.shade100,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                text: "One step at a time",
                color: Colors.green.shade100,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------------- EMOTION CHIP ---------------- */

class _EmotionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _EmotionChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/* ---------------- ACTION BUTTON ---------------- */

class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;

  const _ActionButton({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
