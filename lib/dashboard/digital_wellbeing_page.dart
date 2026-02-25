import 'package:flutter/material.dart';
import 'circular_wellbeing_widget.dart';
import 'pp_detail_page.dart';

class DigitalWellbeingPage extends StatelessWidget {
  const DigitalWellbeingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        title: const Text("Digital Wellbeing"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const CircularWellbeingWidget(
              progress: 0.7,
              timeText: "4h 20m",
            ),

            const SizedBox(height: 30),

            _AppTile(
              name: "YouTube",
              time: "1h 30m",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppDetailPage(appName: "YouTube"),
                  ),
                );
              },
            ),

            _AppTile(
              name: "Instagram",
              time: "2h 10m",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppDetailPage(appName: "Instagram"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final String name;
  final String time;
  final VoidCallback onTap;

  const _AppTile({
    required this.name,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white)),
      subtitle: Text(time, style: const TextStyle(color: Colors.white60)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: onTap,
    );
  }
}