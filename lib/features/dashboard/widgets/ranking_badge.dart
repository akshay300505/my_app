import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';

class RankingBadge extends StatelessWidget {
  const RankingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Your Rank: #12",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Icon(Icons.emoji_events, color: Colors.amber),
        ],
      ),
    );
  }
}