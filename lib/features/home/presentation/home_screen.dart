import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:new_day/core/theme/app_colors.dart';

// SAYFA İMPORTLARI
import 'package:new_day/features/calendar/presentation/calendar_screen.dart';
import 'package:new_day/features/oasis/presentation/oasis_screen.dart';
import 'package:new_day/features/goals/presentation/goals_screen.dart';
// MENÜYÜ BURADAN ÇAĞIRIYORUZ
import 'package:new_day/features/menu/presentation/menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CalendarScreen(), // 0: Bugün
    const OasisScreen(),    // 1: Oasis
    const GoalsScreen(),    // 2: Hedefler
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.calendar),
            selectedIcon: Icon(CupertinoIcons.calendar_today, color: AppColors.primary),
            label: 'Bugün',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.sparkles),
            selectedIcon: Icon(CupertinoIcons.sparkles, color: AppColors.primary),
            label: 'Oasis',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.circle), 
            selectedIcon: Icon(CupertinoIcons.scope, color: AppColors.primary),
            label: 'Hedefler',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.app_badge),
            selectedIcon: Icon(CupertinoIcons.app_badge_fill, color: AppColors.primary),
            label: 'Diğer',
          ),
        ],
      ),
    );
  }
}