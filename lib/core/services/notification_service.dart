import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezones
    try {
      tz.initializeTimeZones();
      debugPrint('Timezones initialized');
    } catch (e) {
      debugPrint('Error initializing timezones: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('Android notification permission granted: $granted');
      
      // Request exact alarm permission for scheduled notifications
      final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
      debugPrint('Exact alarm permission granted: $exactAlarmGranted');
      
      return granted ?? false;
    }
    
    return true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'expense_tracker_channel',
      'Expense Tracker',
      channelDescription: 'Notifications for expense tracking',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
    debugPrint('Notification shown: $title');
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      await cancelNotification(0); // Cancel existing
      
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      
      // If the time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminders',
        channelDescription: 'Daily expense tracking reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

      const details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        0,
        'Track Your Expenses',
        'Don\'t forget to log your spending today! 💰',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      debugPrint('Daily reminder scheduled for ${scheduledDate.hour}:${scheduledDate.minute}');
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  Future<void> scheduleBudgetWarning({
    required String categoryName,
    required double percentage,
  }) async {
    await showNotification(
      id: categoryName.hashCode,
      title: '⚠️ Budget Alert: $categoryName',
      body: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your budget for this category!',
      payload: 'budget_warning',
    );
  }

  Future<void> scheduleWeeklySummary({
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    try {
      await cancelNotification(1); // Cancel existing
      
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      
      // Find next occurrence of the specified day of week
      while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'weekly_summary',
        'Weekly Summary',
        channelDescription: 'Weekly expense summaries',
        importance: Importance.high,
        priority: Priority.high,
      );

      const details = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        1,
        'Weekly Expense Summary',
        'Check out your spending patterns this week! 📊',
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      
      debugPrint('Weekly summary scheduled for day $dayOfWeek at $hour:$minute');
    } catch (e) {
      debugPrint('Error scheduling weekly summary: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('Cancelled notification $id');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }
}
