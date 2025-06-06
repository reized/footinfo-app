import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/fixture.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }

  // Show immediate notification
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'footinfo_channel',
          'Footinfo Notifications',
          channelDescription: 'Match reminders and updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification for specific time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    // Convert to timezone aware datetime
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'footinfo_reminders',
          'Match Reminders',
          channelDescription: 'Scheduled match reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.reminder,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'match_reminder',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('Notification scheduled for: $scheduledTZ');
  }

  // Schedule match reminder (1 hour before)
  static Future<void> scheduleMatchReminder(Fixture fixture) async {
    try {
      // Parse fixture date
      DateTime matchTime = DateTime.parse(fixture.date);

      // Schedule 1 hour before match
      DateTime reminderTime = matchTime.subtract(const Duration(hours: 1));

      // Only schedule if reminder time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: fixture.id,
          title: '⚽ Match Starting Soon!',
          body:
              '${fixture.homeTeamName} vs ${fixture.awayTeamName} starts in 1 hour',
          scheduledTime: reminderTime,
          payload: 'match_${fixture.id}',
        );

        print(
          'Match reminder scheduled for ${fixture.homeTeamName} vs ${fixture.awayTeamName}',
        );
        print('Reminder time: $reminderTime');
      } else {
        print('Match time is too soon to schedule reminder');
      }
    } catch (e) {
      print('Error scheduling match reminder: $e');
    }
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('Notification $id cancelled');
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('All notifications cancelled');
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Check if notification exists
  static Future<bool> hasScheduledNotification(int id) async {
    final pending = await getPendingNotifications();
    return pending.any((notification) => notification.id == id);
  }
}
