import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  Color _getRoleColor(UserRole? role) {
    if (role == null) return AppTheme.primaryColor;
    switch (role) {
      case UserRole.imam:
        return AppTheme.primaryColor;
      case UserRole.donor:
        return AppTheme.secondaryColor;
      case UserRole.beneficiary:
        return Colors.green;
    }
  }

  String _getRoleText(UserRole? role) {
    if (role == null) return 'User';
    switch (role) {
      case UserRole.imam:
        return 'Imam';
      case UserRole.donor:
        return 'Donor';
      case UserRole.beneficiary:
        return 'Beneficiary';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final roleColor = _getRoleColor(user?.role);
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: roleColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          roleColor,
                          ColorUtils.withOpacity(roleColor, 0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.whiteColor,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.name ?? 'Guest User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.whiteColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorUtils.withOpacity(
                                AppTheme.whiteColor,
                                0.2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getRoleText(user?.role),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionHeader('Personal Information', roleColor),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'Name',
                                user?.name ?? 'Not set',
                                Icons.person,
                                roleColor,
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                'CNIC',
                                user?.cnic ?? 'Not set',
                                Icons.credit_card,
                                roleColor,
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                'Phone',
                                user?.phoneNumber ?? 'Not set',
                                Icons.phone,
                                roleColor,
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                'Email',
                                user?.email ?? 'Not set',
                                Icons.email,
                                roleColor,
                              ),
                              _buildDivider(),
                              _buildInfoRow(
                                'Location',
                                user?.location ?? 'Not set',
                                Icons.location_on,
                                roleColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Role-specific Information
                      if (user?.role == UserRole.imam && user?.additionalInfo != null) ...[
                        _buildSectionHeader('Mosque Information', roleColor),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  'Mosque Name',
                                  user?.additionalInfo?['mosqueName'] ?? 'Not set',
                                  Icons.mosque,
                                  roleColor,
                                ),
                                _buildDivider(),
                                _buildInfoRow(
                                  'Mosque Address',
                                  user?.additionalInfo?['mosqueAddress'] ?? 'Not set',
                                  Icons.location_on,
                                  roleColor,
                                ),
                                _buildDivider(),
                                _buildInfoRow(
                                  'Muazzin/Khadim',
                                  user?.additionalInfo?['muazzinKhadim'] ?? 'Not set',
                                  Icons.person_outline,
                                  roleColor,
                                ),
                                _buildDivider(),
                                _buildInfoRow(
                                  'Prayer Count',
                                  '${user?.additionalInfo?['prayerCount'] ?? '0'} people',
                                  Icons.groups,
                                  roleColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Settings Section
                      _buildSectionHeader('Settings', roleColor),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Push Notifications'),
                              subtitle: const Text('Receive important updates'),
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                              activeTrackColor: roleColor,
                              inactiveTrackColor: Colors.grey[300],
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: const Text('Email Notifications'),
                              subtitle: const Text('Receive updates via email'),
                              value: _emailNotifications,
                              onChanged: _notificationsEnabled
                                  ? (value) {
                                      setState(() {
                                        _emailNotifications = value;
                                      });
                                    }
                                  : null,
                              activeTrackColor: roleColor,
                              inactiveTrackColor: Colors.grey[300],
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: const Text('SMS Notifications'),
                              subtitle: const Text('Receive updates via SMS'),
                              value: _smsNotifications,
                              onChanged: _notificationsEnabled
                                  ? (value) {
                                      setState(() {
                                        _smsNotifications = value;
                                      });
                                    }
                                  : null,
                              activeTrackColor: roleColor,
                              inactiveTrackColor: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Actions Section
                      _buildSectionHeader('Actions', roleColor),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.edit,
                                color: roleColor,
                              ),
                              title: const Text('Edit Profile'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Fluttertoast.showToast(
                                  msg: 'Edit profile coming soon',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.lock,
                                color: roleColor,
                              ),
                              title: const Text('Change Password'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Fluttertoast.showToast(
                                  msg: 'Change password coming soon',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.help,
                                color: roleColor,
                              ),
                              title: const Text('Help & Support'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                context.push('/help');
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.info,
                                color: roleColor,
                              ),
                              title: const Text('About'),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                _showAboutDialog();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleLogout(authProvider),
                          icon: const Icon(
                            Icons.logout,
                            color: AppTheme.whiteColor,
                          ),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.whiteColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Muslim Charity Donation Platform',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'A platform connecting donors with verified needy individuals through mosque networks.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                context.go('/role-selection');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}