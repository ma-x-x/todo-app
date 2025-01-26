import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder.dart';
import '../providers/notification_settings_provider.dart';
import 'package:flutter/material.dart' show TimeOfDay;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  late NotificationSettingsProvider _settings;

  NotificationService._() {
    _init();
  }

  void setSettingsProvider(NotificationSettingsProvider settings) {
    _settings = settings;
  }

  Future<void> _init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // TODO: 处理通知点击事件
      },
    );
  }

  Future<void> scheduleNotification(Reminder reminder, String todoTitle) async {
    if (!_settings.enabled || reminder.notifyType != 'push') return;
    if (_settings.quietHoursEnabled && _settings.isQuietTime()) return;

    final id = reminder.id ?? DateTime.now().millisecondsSinceEpoch % 100000;

    final androidDetails = AndroidNotificationDetails(
      'todo_reminders',
      '待办提醒',
      channelDescription: '待办事项提醒通知',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: _settings.vibrationEnabled,
      playSound: _settings.soundEnabled,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: _settings.soundEnabled,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    switch (reminder.remindType) {
      case 'once':
        final scheduledDate = tz.TZDateTime.from(reminder.remindAt, tz.local);
        if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

        await _notifications.zonedSchedule(
          id,
          '待办提醒',
          todoTitle,
          scheduledDate,
          details,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        break;

      case 'daily':
        await _notifications.zonedSchedule(
          id,
          '每日提醒',
          todoTitle,
          _nextInstanceOfTime(reminder.remindAt),
          details,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        break;

      case 'weekly':
        await _notifications.zonedSchedule(
          id,
          '每周提醒',
          todoTitle,
          _nextInstanceOfTime(reminder.remindAt),
          details,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        break;
    }
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime dateTime) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 如果在勿扰时段内，则推迟到勿扰时段结束
    if (_settings.quietHoursEnabled && _isInQuietHours(scheduledDate)) {
      final endTime = _settings.quietHoursEnd;
      scheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        endTime.hour,
        endTime.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }

    return scheduledDate;
  }

  bool _isInQuietHours(tz.TZDateTime dateTime) {
    if (!_settings.quietHoursEnabled) return false;

    final timeOfDay = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    final minutes = timeOfDay.hour * 60 + timeOfDay.minute;
    final startMinutes = _settings.quietHoursStart.hour * 60 + 
                        _settings.quietHoursStart.minute;
    final endMinutes = _settings.quietHoursEnd.hour * 60 + 
                      _settings.quietHoursEnd.minute;

    if (startMinutes <= endMinutes) {
      return minutes >= startMinutes && minutes <= endMinutes;
    } else {
      return minutes >= startMinutes || minutes <= endMinutes;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> requestPermissions() async {
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    await _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  TimeOfDay _timeFromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
} 