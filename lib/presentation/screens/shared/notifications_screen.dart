import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Donation Received',
      message: 'You received a donation of PKR 5,000 for your case',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      type: NotificationType.donation,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Case Approved',
      message: 'Your case has been approved by the imam',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.caseUpdate,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Verification Required',
      message: 'Please verify the beneficiary information',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.verification,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Monthly Report',
      message: 'Your monthly donation report is ready',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.report,
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'New Case Available',
      message: 'A new medical emergency case needs your support',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.newCase,
      isRead: true,
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationTile(notification);
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
  
  Widget _buildNotificationTile(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppTheme.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: AppTheme.whiteColor,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notifications.add(notification);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        color: notification.isRead ? null : ColorUtils.withOpacity(AppTheme.primaryColor, 0.05),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getIcon(notification.type),
              color: _getIconColor(notification.type),
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification.time),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            if (!notification.isRead) {
              setState(() {
                notification.isRead = true;
              });
            }
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }
  
  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.donation:
        return Icons.attach_money;
      case NotificationType.caseUpdate:
        return Icons.update;
      case NotificationType.verification:
        return Icons.verified_user;
      case NotificationType.report:
        return Icons.assessment;
      case NotificationType.newCase:
        return Icons.fiber_new;
    }
  }
  
  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.donation:
        return AppTheme.successColor;
      case NotificationType.caseUpdate:
        return AppTheme.primaryColor;
      case NotificationType.verification:
        return Colors.orange;
      case NotificationType.report:
        return Colors.purple;
      case NotificationType.newCase:
        return AppTheme.secondaryColor;
    }
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
  
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }
  
  void _handleNotificationTap(NotificationItem notification) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.donation:
        // Navigate to donation history
        break;
      case NotificationType.caseUpdate:
        // Navigate to case details
        break;
      case NotificationType.verification:
        // Navigate to verification screen
        break;
      case NotificationType.report:
        // Navigate to reports
        break;
      case NotificationType.newCase:
        // Navigate to browse cases
        break;
    }
  }
}

enum NotificationType {
  donation,
  caseUpdate,
  verification,
  report,
  newCase,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;
  
  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });
}