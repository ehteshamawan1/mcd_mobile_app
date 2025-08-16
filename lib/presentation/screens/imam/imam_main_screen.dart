import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import 'imam_dashboard_screen.dart';
import 'case_management_screen.dart';
import 'beneficiary_verification_screen.dart';
import '../shared/profile_screen.dart';

class ImamMainScreen extends StatefulWidget {
  const ImamMainScreen({super.key});

  @override
  State<ImamMainScreen> createState() => _ImamMainScreenState();
}

class _ImamMainScreenState extends State<ImamMainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const ImamDashboardScreen(),
    const CaseManagementScreen(),
    const BeneficiaryVerificationScreen(),
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
        indicatorColor: AppTheme.primaryColor.withAlpha(26),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryColor),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder, color: AppTheme.primaryColor),
            label: 'Cases',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified, color: AppTheme.primaryColor),
            label: 'Verify',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}