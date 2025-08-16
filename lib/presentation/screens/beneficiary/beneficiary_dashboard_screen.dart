import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';

class BeneficiaryDashboardScreen extends StatelessWidget {
  const BeneficiaryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiary Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/role-selection');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Beneficiary Dashboard - Coming Soon'),
      ),
    );
  }
}