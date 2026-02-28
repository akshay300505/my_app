import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: "Study",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Wellbeing",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: "Time",
        ),
      ],
    );
  }
}