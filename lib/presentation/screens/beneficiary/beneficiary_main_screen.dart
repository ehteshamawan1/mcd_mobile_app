import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import 'beneficiary_dashboard_screen.dart';
import 'my_cases_screen.dart';
import 'submit_case_screen.dart';
import '../shared/profile_screen.dart';

class BeneficiaryMainScreen extends StatefulWidget {
  const BeneficiaryMainScreen({super.key});

  @override
  State<BeneficiaryMainScreen> createState() => _BeneficiaryMainScreenState();
}

class _BeneficiaryMainScreenState extends State<BeneficiaryMainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const BeneficiaryDashboardScreen(),
    const MyCasesScreen(),
    const SubmitCaseScreen(),
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
        indicatorColor: Colors.green.withAlpha(26),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Colors.green),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder, color: Colors.green),
            label: 'My Cases',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Colors.green),
            label: 'Submit',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.green),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}