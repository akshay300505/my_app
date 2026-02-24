import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DigitalWellbeingPage extends StatelessWidget {
  const DigitalWellbeingPage({super.key});

  // Screen usage across all devices
  static const Map<String, double> usageData = {
    "Instagram": 2.0,
    "YouTube": 1.8,
    "WhatsApp": 1.2,
    "Facebook": 0.6,
    "Twitter (X)": 0.5,
    "Snapchat": 0.7,
    "LinkedIn": 0.4,
    "Study Apps": 1.5,
    "Entertainment": 1.0,
  };

  double get totalHours =>
      usageData.values.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        title: const Text("Digital Wellbeing"),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TOTAL SCREEN TIME
            Text(
              "Total Screen Time (All Devices)",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800),
            ),

            const SizedBox(height: 8),

            Text(
              "${totalHours.toStringAsFixed(1)} Hours Today\n(Mobile • Laptop • Tablet)",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            const Text(
              "Usage Breakdown",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _buildSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "App Usage Details",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: usageData.entries.map((entry) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.apps),
                      title: Text(entry.key),
                      trailing: Text(
                        "${entry.value.toStringAsFixed(1)} h",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colors = [
      Colors.purple,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];

    int index = 0;

    return usageData.entries.map((entry) {
      final value = entry.value;
      final percentage = (value / totalHours) * 100;

      final section = PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: "${percentage.toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );

      index++;
      return section;
    }).toList();
  }
}