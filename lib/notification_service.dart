import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
static Future<void> init() async {
await AwesomeNotifications().initialize(
null,
[
NotificationChannel(
channelKey: 'skedule_channel',
channelName: 'Class Reminders',
channelDescription: 'Reminder for class schedules',
defaultColor: Color(0xFF9D50DD),
ledColor: Color(0xFF9D50DD),
importance: NotificationImportance.High,
channelShowBadge: true,
),
],
debug: true,
);
}

static Future<void> showTestNotification() async {
await AwesomeNotifications().createNotification(
content: NotificationContent(
id: 1,
channelKey: 'skedule_channel',
title: 'Test Reminder',
body: 'This is a test notification from Skedule!',
),
);
}
}