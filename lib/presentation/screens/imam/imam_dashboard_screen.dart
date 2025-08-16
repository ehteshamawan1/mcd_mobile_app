import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/case_provider.dart';

class ImamDashboardScreen extends StatelessWidget {
  const ImamDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final caseProvider = Provider.of<CaseProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imam Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              context.push('/imam/notifications');
            },
          ),
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
      body: RefreshIndicator(
        onRefresh: () => caseProvider.loadCases(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: AppTheme.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Assalam-o-Alaikum',
                        style: TextStyle(
                          color: AppTheme.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        authProvider.user?.name ?? 'Imam',
                        style: const TextStyle(
                          color: AppTheme.whiteColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authProvider.user?.additionalInfo?['mosqueName'] ?? 'Mosque',
                        style: const TextStyle(
                          color: AppTheme.whiteColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Statistics Row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Cases',
                      value: '${caseProvider.allCases.length}',
                      icon: Icons.folder,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Pending',
                      value: '${caseProvider.getPendingCases().length}',
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Active',
                      value: '${caseProvider.getActiveCases().length}',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Raised',
                      value: 'PKR ${_calculateTotalRaised(caseProvider)}',
                      icon: Icons.monetization_on,
                      color: AppTheme.secondaryColor,
                      isMonetary: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add,
                      label: 'Add Case',
                      color: AppTheme.primaryColor,
                      onTap: () {
                        context.push('/imam/create-case');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.verified_user,
                      label: 'Verify Cases',
                      color: Colors.green,
                      onTap: () {
                        context.push('/imam/verify');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Recent Cases
              const Text(
                'Recent Cases',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...caseProvider.allCases.take(5).map((caseModel) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCaseTypeColor(caseModel.type.toString()),
                    child: Icon(
                      _getCaseTypeIcon(caseModel.type.toString()),
                      color: AppTheme.whiteColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    caseModel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${caseModel.beneficiaryName} • PKR ${caseModel.targetAmount.toStringAsFixed(0)}',
                  ),
                  trailing: Chip(
                    label: Text(
                      caseModel.status.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(caseModel.status.toString()),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/imam/create-case');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _calculateTotalRaised(CaseProvider provider) {
    final total = provider.allCases.fold<double>(
      0,
      (sum, caseModel) => sum + caseModel.raisedAmount,
    );
    return total.toStringAsFixed(0);
  }

  Color _getCaseTypeColor(String type) {
    switch (type) {
      case 'medical':
        return Colors.red;
      case 'education':
        return Colors.blue;
      case 'emergency':
        return Colors.orange;
      case 'housing':
        return Colors.purple;
      case 'food':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCaseTypeIcon(String type) {
    switch (type) {
      case 'medical':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'emergency':
        return Icons.warning;
      case 'housing':
        return Icons.home;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return ColorUtils.withOpacity(Colors.orange, 0.2);
      case 'active':
        return ColorUtils.withOpacity(Colors.green, 0.2);
      case 'completed':
        return ColorUtils.withOpacity(Colors.blue, 0.2);
      case 'rejected':
        return ColorUtils.withOpacity(Colors.red, 0.2);
      default:
        return ColorUtils.withOpacity(Colors.grey, 0.2);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isMonetary;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isMonetary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.greyColor,
                fontSize: 12,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: ColorUtils.withOpacity(color, 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorUtils.withOpacity(color, 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}