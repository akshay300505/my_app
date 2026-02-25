import 'package:flutter/material.dart';
import 'wellbeing_graph_widget.dart';

class AppDetailPage extends StatefulWidget {
  final String appName;

  const AppDetailPage({super.key, required this.appName});

  @override
  State<AppDetailPage> createState() => _AppDetailPageState();
}

class _AppDetailPageState extends State<AppDetailPage> {
  String selected = "Daily";

  List<double> getData() {
    if (selected == "Weekly") {
      return [120, 90, 140, 80, 70, 110, 95];
    } else if (selected == "Monthly") {
      return List.generate(10, (i) => (i + 1) * 20);
    }
    return [50, 60, 40, 70, 90, 30, 80, 55, 65, 75];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        title: Text(widget.appName),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// Filter Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ["Daily", "Weekly", "Monthly"].map((filter) {
              final isSelected = filter == selected;
              return GestureDetector(
                onTap: () => setState(() => selected = filter),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4FC3F7)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          /// Graph
          WellbeingGraphWidget(data: getData()),
        ],
      ),
    );
  }
}