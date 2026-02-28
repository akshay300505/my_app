import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';

class FamilySupportCard extends StatelessWidget {
  const FamilySupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: const Icon(Icons.family_restroom),
        title: const Text("Family Support"),
        subtitle: const Text("Weekly interaction insights"),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}