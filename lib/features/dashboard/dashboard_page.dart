import 'package:flutter/material.dart';
import 'widgets/welcome_header.dart';
import 'widgets/balance_score_card.dart';
import 'widgets/digital_wellbeing_card.dart';
import 'widgets/analytics_card.dart';
import 'widgets/ai_audio_card.dart';
import 'widgets/time_management_card.dart';
import 'widgets/family_support_card.dart';
import 'widgets/ranking_badge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                WelcomeHeader(),
                SizedBox(height: 20),
                RankingBadge(),
                SizedBox(height: 20),
                BalanceScoreCard(),
                SizedBox(height: 20),
                DigitalWellbeingCard(),
                SizedBox(height: 20),
                AnalyticsCard(),
                SizedBox(height: 20),
                AIAudioCard(),
                SizedBox(height: 20),
                TimeManagementCard(),
                SizedBox(height: 20),
                FamilySupportCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}