import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';

class ImamNotificationsScreen extends StatefulWidget {
  const ImamNotificationsScreen({super.key});

  @override
  State<ImamNotificationsScreen> createState() => _ImamNotificationsScreenState();
}

class _ImamNotificationsScreenState extends State<ImamNotificationsScreen> {
  String _selectedFilter = 'All';
  
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Case Pending Verification',
      'message': 'A new case has been submitted by Ali Hassan and requires your verification.',
      'type': 'case_verification',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Case Approved by Admin',
      'message': 'The case for Sara Ahmed has been approved by the administrator.',
      'type': 'case_approved',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'Monthly Report Available',
      'message': 'Your monthly mosque charity report is now available for review.',
      'type': 'report',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'Donation Milestone Reached',
      'message': 'The medical case for Ahmad Khan has reached 75% of its target amount.',
      'type': 'donation_milestone',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
    },
    {
      'id': '5',
      'title': 'New Beneficiary Registration',
      'message': 'Fatima Bibi has registered as a beneficiary and needs verification.',
      'type': 'beneficiary_registration',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
    },
    {
      'id': '6',
      'title': 'Case Completed Successfully',
      'message': 'The education support case for Zainab has been completed successfully.',
      'type': 'case_completed',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    } else if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !n['isRead']).toList();
    } else {
      return _notifications.where((n) => n['type'] == _selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, color: AppTheme.whiteColor),
            label: const Text(
              'Mark All Read',
              style: TextStyle(color: AppTheme.whiteColor),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Unread'),
                const SizedBox(width: 8),
                _buildFilterChip('case_verification', label: 'Verifications'),
                const SizedBox(width: 8),
                _buildFilterChip('case_approved', label: 'Approvals'),
                const SizedBox(width: 8),
                _buildFilterChip('report', label: 'Reports'),
              ],
            ),
          ),
          
          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredNotifications.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, {String? label}) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label ?? filter),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      backgroundColor: AppTheme.whiteColor,
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.whiteColor : AppTheme.primaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead ? AppTheme.whiteColor : ColorUtils.withOpacity(AppTheme.primaryColor, 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(type),
          child: Icon(
            _getTypeIcon(type),
            color: AppTheme.whiteColor,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'mark_read') {
              _markAsRead(notification['id']);
            } else if (value == 'delete') {
              _deleteNotification(notification['id']);
            }
          },
          itemBuilder: (context) => [
            if (!isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Text('Mark as Read'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'case_verification':
        return Colors.orange;
      case 'case_approved':
        return Colors.green;
      case 'case_completed':
        return Colors.blue;
      case 'report':
        return Colors.purple;
      case 'donation_milestone':
        return AppTheme.secondaryColor;
      case 'beneficiary_registration':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'case_verification':
        return Icons.verified_user;
      case 'case_approved':
        return Icons.check_circle;
      case 'case_completed':
        return Icons.task_alt;
      case 'report':
        return Icons.assessment;
      case 'donation_milestone':
        return Icons.trending_up;
      case 'beneficiary_registration':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n['id'] == id);
      notification['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Navigate based on notification type
    switch (notification['type']) {
      case 'case_verification':
        context.push('/imam/verify');
        break;
      case 'case_approved':
      case 'case_completed':
        context.go('/imam/dashboard');
        break;
      default:
        break;
    }
  }
}