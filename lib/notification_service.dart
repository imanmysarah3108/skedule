import 'package:flutter/material.dart'; // Added for @required in some Flutter versions, or for specific types
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart'; // For NotificationDetails

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize timezone for scheduling notifications (if you plan to use it)
    tz.initializeTimeZones();
    // Configure local time zone (e.g., to your device's current time zone)
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur')); // IMPORTANT: Adjust this to your actual timezone if needed

    // Initialize platform-specific settings
    // Android setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Your app icon

    // iOS/macOS setup
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle notification received in foreground
        // For simple apps, you might show a dialog or refresh UI
        debugPrint('iOS foreground notification: $id, $title, $body, $payload');
      },
    );

    // General initialization settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    // Perform initialization
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // Handle notification tap when app is in foreground, background, or terminated
        final String? payload = notificationResponse.payload;
        if (notificationResponse.payload != null) {
          debugPrint('notification payload: $payload');
        }
        // Example: Navigate to a specific screen based on payload
        // if (payload == 'some_data') {
        //   Navigator.push(context, MaterialPageRoute(builder: (_) => SomeDetailScreen()));
        // }
      },
      onDidReceiveBackgroundNotificationResponse: (NotificationResponse notificationResponse) async {
        // This is called when a notification is tapped while the app is terminated or in the background.
        // Needs a top-level function. We can leave it empty for now, or define a handler.
        debugPrint('background notification payload: ${notificationResponse.payload}');
      }
    );

    // Create a notification channel (for Android 8.0+)
    const AndroidNotificationChannel skeduleChannel = AndroidNotificationChannel(
      'skedule_channel', // id
      'Class Reminders', // name
      description: 'Reminder for class schedules', // description
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(skeduleChannel);

    debugPrint('FlutterLocalNotificationsPlugin initialized and channel created.');
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'skedule_channel', // Must match the channel ID created above
      'Class Reminders',
      channelDescription: 'Reminder for class schedules',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker', // For older Android versions
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(); // Can customize if needed

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      1, // Notification ID
      'Test Reminder',
      'This is a test notification from Skedule (Local Notifications)!',
      platformChannelSpecifics,
      payload: 'test_payload',
    );
  }

  // Example of scheduling a notification for 5 seconds from now
  static Future<void> scheduleNotification() async {
    await _notificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Scheduled Reminder',
      'This notification was scheduled!',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)), // 5 seconds from now
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'skedule_channel',
          'Class Reminders',
          channelDescription: 'Reminder for class schedules',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'scheduled_payload',
    );
  }
}

// IMPORTANT: This top-level function is required for background notification handling on Android.
// It must be a static function or a top-level function declared outside any class.
@pragma('vm:entry-point') // Required for Flutter versions >= 3.x
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handle notification tap when app is terminated or in the background
  debugPrint('background notification response payload: ${notificationResponse.payload}');
  // You can route to a specific page or perform actions here, but be careful
  // as the Flutter engine might not be fully initialized or UI context might not be available.
  // For example, you can use a custom logger or save to shared preferences.
}