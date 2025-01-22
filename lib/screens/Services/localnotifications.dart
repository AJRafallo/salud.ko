import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  // same plugin reference
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // >>> CHANGE #1: Add requestAlertPermission, requestBadgePermission, requestSoundPermission to iOS settings
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: Prompt for permission on first run
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      // onDidReceiveLocalNotification: ... (optional)
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Optional: handle tapping on a notification
    print('Notification tapped: ${response.payload}');
  }

  // >>> REMOVED "showTestNotification" method entirely

  // same scheduleNotification method
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    bool repeatDaily = false,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(dateTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicines_channel_id',
          'Medicines Reminders',
          channelDescription: 'Reminder notifications for medicines',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
      // Must specify in v15+:
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime.from(dateTime, tz.local);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
