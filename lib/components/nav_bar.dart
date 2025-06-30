// components/nav_bar.dart
import 'package:flutter/material.dart';
import 'package:skedule/theme/colors.dart';

class FuturisticNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FuturisticNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: const Color.fromARGB(255, 118, 51, 157),
      selectedItemColor: const Color.fromARGB(255, 255, 62, 62),
      unselectedItemColor: const Color.fromARGB(255, 212, 212, 212),
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.today),
          label: 'Today',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Assignments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}