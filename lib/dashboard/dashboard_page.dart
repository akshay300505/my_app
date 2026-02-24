import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'study_card.dart';
import 'emotion_card.dart';
import 'digital_wellbeing_card.dart';
import 'edit_profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color lightCream = Color(0xFFF7F9F9);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isWideScreen = width >= 900;

    return Scaffold(
      backgroundColor: lightCream,
      body: SafeArea(
        child: Column(
          children: [
            const _ProfileHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: isWideScreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(child: StudyCard()),
                          SizedBox(width: 16),
                          Expanded(child: EmotionCard()),
                          SizedBox(width: 16),
                          Expanded(child: DigitalWellbeingCard()),
                        ],
                      )
                    : Column(
                        children: const [
                          StudyCard(),
                          SizedBox(height: 16),
                          EmotionCard(),
                          SizedBox(height: 16),
                          DigitalWellbeingCard(),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final data = snapshot.data!;
        final String name = data['name'] ?? "User";
        final String userClass = data['class'] ?? "";
        final String region = data['region'] ?? "";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                /// Avatar
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF4A90E2),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "U",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                /// User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (userClass.isNotEmpty) Text(userClass),
                      if (region.isNotEmpty) Text(region),
                    ],
                  ),
                ),

                /// Edit Button
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}