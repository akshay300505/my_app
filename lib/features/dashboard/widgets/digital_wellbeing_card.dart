import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';

class DigitalWellbeingCard extends StatelessWidget {
  const DigitalWellbeingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: const Icon(Icons.phone_android),
        title: const Text("Digital Wellbeing"),
        subtitle: const Text("Screen time: 3h 20m"),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}