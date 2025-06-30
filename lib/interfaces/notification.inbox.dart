import 'package:flutter/material.dart';
import 'package:skedule/theme/colors.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() => _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  // Empty list to simulate no notifications
  final List<Map<String, dynamic>> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: AppColors.text.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You don't have any notifications",
                    style: TextStyle(
                      color: AppColors.text.withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: notification['isRead'] ? AppColors.card : AppColors.accent,
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: notification['isRead'] ? AppColors.secondary : AppColors.primary,
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    subtitle: Text(
                      notification['message'],
                      style: TextStyle(
                        color: AppColors.text.withOpacity(0.7),
                      ),
                    ),
                    trailing: Text(
                      notification['time'],
                      style: TextStyle(
                        color: AppColors.text.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        notification['isRead'] = true;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}