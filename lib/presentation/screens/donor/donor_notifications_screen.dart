import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';

class DonorNotificationsScreen extends StatefulWidget {
  const DonorNotificationsScreen({super.key});

  @override
  State<DonorNotificationsScreen> createState() => _DonorNotificationsScreenState();
}

class _DonorNotificationsScreenState extends State<DonorNotificationsScreen> {
  String _selectedFilter = 'All';
  
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Donation Successful',
      'message': 'Your donation of PKR 5,000 to Sara Ahmed\'s medical case has been received.',
      'type': 'donation_success',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Case Update',
      'message': 'The education case you supported has reached 80% of its goal!',
      'type': 'case_update',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'Thank You Message',
      'message': 'Ahmad Khan has sent you a thank you message for your generous donation.',
      'type': 'thank_you',
      'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'Case Completed',
      'message': 'The medical case for Fatima Bibi that you supported has been successfully completed.',
      'type': 'case_completed',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
    },
    {
      'id': '5',
      'title': 'New Urgent Case',
      'message': 'An urgent medical case has been posted in your area that needs immediate support.',
      'type': 'new_case',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
    },
    {
      'id': '6',
      'title': 'Monthly Impact Report',
      'message': 'Your monthly impact report is ready. You\'ve helped 3 families this month!',
      'type': 'impact_report',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
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
        backgroundColor: AppTheme.secondaryColor,
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
                _buildFilterChip('donation_success', label: 'Donations'),
                const SizedBox(width: 8),
                _buildFilterChip('case_update', label: 'Updates'),
                const SizedBox(width: 8),
                _buildFilterChip('thank_you', label: 'Thank You'),
                const SizedBox(width: 8),
                _buildFilterChip('new_case', label: 'New Cases'),
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
      selectedColor: AppTheme.secondaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.whiteColor : AppTheme.secondaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.secondaryColor : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead ? AppTheme.whiteColor : ColorUtils.withOpacity(AppTheme.secondaryColor, 0.05),
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
      case 'donation_success':
        return Colors.green;
      case 'case_update':
        return Colors.blue;
      case 'case_completed':
        return AppTheme.primaryColor;
      case 'thank_you':
        return Colors.pink;
      case 'new_case':
        return Colors.orange;
      case 'impact_report':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'donation_success':
        return Icons.volunteer_activism;
      case 'case_update':
        return Icons.update;
      case 'case_completed':
        return Icons.check_circle;
      case 'thank_you':
        return Icons.favorite;
      case 'new_case':
        return Icons.new_releases;
      case 'impact_report':
        return Icons.assessment;
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
      case 'donation_success':
        context.push('/donor/history');
        break;
      case 'new_case':
        context.push('/donor/browse');
        break;
      case 'case_update':
      case 'case_completed':
        context.go('/donor/dashboard');
        break;
      default:
        break;
    }
  }
}