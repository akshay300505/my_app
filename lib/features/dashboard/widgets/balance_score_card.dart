import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';

class BalanceScoreCard extends StatelessWidget {
  const BalanceScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Balance Score",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          LinearProgressIndicator(value: 0.75),
          SizedBox(height: 6),
          Text("75% Balanced"),
        ],
      ),
    );
  }
}