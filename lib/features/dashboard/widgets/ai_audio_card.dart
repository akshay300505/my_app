import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';

class AIAudioCard extends StatelessWidget {
  const AIAudioCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: const Icon(Icons.headphones),
        title: const Text("AI Audio Therapy"),
        subtitle: const Text("Relax & focus sessions"),
        trailing: const Icon(Icons.play_circle_fill),
      ),
    );
  }
}