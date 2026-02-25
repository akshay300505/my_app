import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WellbeingGraphWidget extends StatelessWidget {
  final List<double> data;

  const WellbeingGraphWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          barGroups: List.generate(
            data.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[index],
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFF4FC3F7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}