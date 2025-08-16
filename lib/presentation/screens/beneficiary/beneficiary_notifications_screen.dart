import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';

class BeneficiaryNotificationsScreen extends StatefulWidget {
  const BeneficiaryNotificationsScreen({super.key});

  @override
  State<BeneficiaryNotificationsScreen> createState() => _BeneficiaryNotificationsScreenState();
}

class _BeneficiaryNotificationsScreenState extends State<BeneficiaryNotificationsScreen> {
  String _selectedFilter = 'All';
  
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Case Verified by Imam',
      'message': 'Your medical case has been verified by the Imam and is now pending admin approval.',
      'type': 'case_verified',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 45)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Donation Received',
      'message': 'You have received a donation of PKR 10,000 for your education case.',
      'type': 'donation_received',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'Case Approved',
      'message': 'Great news! Your housing support case has been approved and is now live.',
      'type': 'case_approved',
      'timestamp': DateTime.now().subtract(const Duration(hours: 12)),
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'Documents Required',
      'message': 'Please upload additional documents for your emergency case verification.',
      'type': 'documents_required',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
    },
    {
      'id': '5',
      'title': 'Case Goal Reached',
      'message': 'Congratulations! Your medical case has reached its funding goal.',
      'type': 'goal_reached',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
    },
    {
      'id': '6',
      'title': 'Monthly Update',
      'message': 'Your case has received 5 donations this month totaling PKR 25,000.',
      'type': 'monthly_update',
      'timestamp': DateTime.now().subtract(const Duration(days: 7)),
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
        backgroundColor: Colors.green,
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
                _buildFilterChip('case_verified', label: 'Verifications'),
                const SizedBox(width: 8),
                _buildFilterChip('donation_received', label: 'Donations'),
                const SizedBox(width: 8),
                _buildFilterChip('case_approved', label: 'Approvals'),
                const SizedBox(width: 8),
                _buildFilterChip('documents_required', label: 'Documents'),
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
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.whiteColor : Colors.green,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.green : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead ? AppTheme.whiteColor : ColorUtils.withOpacity(Colors.green, 0.05),
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
      case 'case_verified':
        return Colors.blue;
      case 'case_approved':
        return Colors.green;
      case 'donation_received':
        return AppTheme.secondaryColor;
      case 'documents_required':
        return Colors.orange;
      case 'goal_reached':
        return Colors.purple;
      case 'monthly_update':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'case_verified':
        return Icons.verified;
      case 'case_approved':
        return Icons.check_circle;
      case 'donation_received':
        return Icons.attach_money;
      case 'documents_required':
        return Icons.description;
      case 'goal_reached':
        return Icons.flag;
      case 'monthly_update':
        return Icons.calendar_month;
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
      case 'documents_required':
        context.push('/beneficiary/my-cases');
        break;
      case 'donation_received':
      case 'goal_reached':
        context.push('/beneficiary/my-cases');
        break;
      case 'case_approved':
      case 'case_verified':
        context.go('/beneficiary/dashboard');
        break;
      default:
        break;
    }
  }
}