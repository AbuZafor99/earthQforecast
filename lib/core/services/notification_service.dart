import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel IDs for different priority levels
  static const String _highPriorityChannelId = 'earthquake_alerts_high';
  static const String _normalPriorityChannelId = 'earthquake_alerts_normal';

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          requestCriticalPermission: true, // For high-priority alerts
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    // Request permissions
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await Permission.notification.request();
    }
  }

  /// Show high-priority notification (for same-continent earthquakes)
  Future<void> showHighPriorityNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          _highPriorityChannelId,
          'Critical Earthquake Alerts',
          channelDescription:
              'High-priority notifications for nearby earthquakes',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: 'ic_notification',
          enableVibration: true,
          playSound: true,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.alarm,
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Show normal-priority notification (for other-continent earthquakes)
  Future<void> showNormalPriorityNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          _normalPriorityChannelId,
          'Earthquake Updates',
          channelDescription: 'Notifications for earthquakes worldwide',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          ticker: 'ticker',
          icon: 'ic_notification',
          enableVibration: false,
          playSound: false,
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
          interruptionLevel: InterruptionLevel.passive,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Legacy method for backward compatibility
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Default to high priority for backward compatibility
    await showHighPriorityNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
  }
}
