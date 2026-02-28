import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';

class TimeManagementCard extends StatelessWidget {
  const TimeManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text("Time Management"),
        subtitle: const Text("5 tasks pending today"),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}