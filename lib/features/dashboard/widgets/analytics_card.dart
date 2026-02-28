import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: const Icon(Icons.bar_chart),
        title: const Text("Analytics Overview"),
        subtitle: const Text("View your performance insights"),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}