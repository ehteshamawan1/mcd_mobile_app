import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import 'donor_dashboard_screen.dart';
import 'browse_cases_screen.dart';
import 'donation_history_screen.dart';
import '../shared/profile_screen.dart';

class DonorMainScreen extends StatefulWidget {
  const DonorMainScreen({super.key});

  @override
  State<DonorMainScreen> createState() => _DonorMainScreenState();
}

class _DonorMainScreenState extends State<DonorMainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DonorDashboardScreen(),
    const BrowseCasesScreen(),
    const DonationHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppTheme.whiteColor,
        indicatorColor: AppTheme.secondaryColor.withAlpha(26),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.secondaryColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: AppTheme.secondaryColor),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppTheme.secondaryColor),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.secondaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}