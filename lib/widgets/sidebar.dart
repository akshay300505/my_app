import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const Sidebar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.blueGrey.shade900,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildItem(Icons.dashboard, "Dashboard", 0),
          _buildItem(Icons.school, "Study", 1),
          _buildItem(Icons.favorite, "Wellbeing", 2),
          _buildItem(Icons.access_time, "Time", 3),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      selected: selectedIndex == index,
      onTap: () => onItemSelected(index),
    );
  }
}