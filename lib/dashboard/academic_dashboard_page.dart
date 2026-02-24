import 'package:flutter/material.dart';
import 'study_card.dart'; // your existing StudyCard
import 'circular_progress_widget.dart';

class AcademicDashboardPage extends StatelessWidget {
  const AcademicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Academic Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row of circular progress widgets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                CircularProgressWidget(
                  progress: 0.7,
                  label: "Math",
                  color: Colors.blue,
                ),
                CircularProgressWidget(
                  progress: 0.5,
                  label: "Physics",
                  color: Colors.greenAccent,
                ),
                CircularProgressWidget(
                  progress: 0.9,
                  label: "Chemistry",
                  color: Colors.orangeAccent,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Study Planner Card with Hero animation
            Hero(
              tag: 'study-card',
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) =>
                          const StudyPlannerPage(),
                    ),
                  );
                },
                child: const StudyCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create a simple StudyPlannerPage for demonstration
class StudyPlannerPage extends StatelessWidget {
  const StudyPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Study Planner"),
      ),
      body: Center(
        child: Hero(
          tag: 'study-card',
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Study Planner",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  "Here you can manage your study sessions and track your progress.",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}