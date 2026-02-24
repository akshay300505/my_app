import 'package:flutter/material.dart';
import 'academic_dashboard_page.dart'; // Import the page you want to navigate to

class StudyCard extends StatelessWidget {
  const StudyCard({super.key});

  static const Color softBlue = Color(0xFFD8EAFB);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'study-card', // Hero tag for smooth animation
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => const StudyPlannerPage(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: softBlue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Smart Study Support",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Today",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mood selector
              Row(
                children: const [
                  _MoodChip(label: "😊 Calm", color: Colors.green),
                  SizedBox(width: 8),
                  _MoodChip(label: "🙂 Okay", color: Colors.orange),
                  SizedBox(width: 8),
                  _MoodChip(label: "😣 Stressed", color: Colors.redAccent),
                ],
              ),
              const SizedBox(height: 16),

              // Task list
              const _TaskItem(
                title: "Organic Chemistry",
                subtitle: "Read Chapter 5",
                completed: true,
              ),
              const _TaskItem(
                title: "Math Practice",
                subtitle: "Solve 20 problems",
                progress: 0.6,
              ),
              const _TaskItem(
                title: "Revise Physics",
                subtitle: "Optics Notes",
                optional: true,
              ),
              const SizedBox(height: 16),

              // Start Timer Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6FB1FC),
                      Color(0xFF4A90E2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Start Timer",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Footer
              const Center(
                child: Text(
                  "Small steps count.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- MOOD CHIP ---------------- */

class _MoodChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MoodChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/* ---------------- TASK ITEM ---------------- */

class _TaskItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool completed;
  final bool optional;
  final double progress;

  const _TaskItem({
    required this.title,
    required this.subtitle,
    this.completed = false,
    this.optional = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle
                : optional
                    ? Icons.radio_button_unchecked
                    : Icons.circle_outlined,
            color: completed
                ? Colors.green
                : optional
                    ? Colors.grey
                    : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                if (progress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.black12,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF4A90E2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (optional)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                "Optional",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}