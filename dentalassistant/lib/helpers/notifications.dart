import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  late final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  NotificationHelper() {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initialize();
  }

  void _initialize() {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _localNotificationsPlugin.initialize(initSettings);
  }

  Future<void> requestPermission() async {
    final permissionGranted = await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (permissionGranted == false) {
      // Handle case where permission is not granted.
      print('Notification permission denied');
    }
  }

  Future<void> sendNotification({
    required String title,
    required String message,
    String channelId = 'default_channel_id',
    String channelName = 'Default Channel',
    String channelDescription = 'Default Channel Description',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'Default Channel Description',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotificationsPlugin.show(
        0, // Notification ID
        title,
        message,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}
