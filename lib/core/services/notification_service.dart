import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import 'storage_service.dart';

class NotificationService {
  NotificationService(this._storage);

  final StorageService _storage;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones(); 
    tz.setLocalLocation(tz.getLocation('Asia/Damascus'));
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.dailyReminderChannelId,
        AppConstants.dailyReminderChannelName,
        description: AppConstants.dailyReminderChannelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;

    if (_storage.notificationEnabled) {
      await scheduleDailyReminder(
        hour: _storage.dailyReminderHour,
        minute: _storage.dailyReminderMinute,
      );
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        return false;
      }
    } else if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted =
          await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      if (!granted) return false;
    }
    return true;
  }

  Future<void> enableDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final granted = await requestPermission();
    if (!granted) {
      throw const PermissionException(
        'لم يتم منح إذن الإشعارات. فعّل الإذن من إعدادات الجهاز.',
      );
    }

    await _storage.setNotificationEnabled(true);
    await _storage.setDailyReminderTime(hour, minute);
    await scheduleDailyReminder(hour: hour, minute: minute);
  }

  Future<void> disableDailyReminder() async {
    await _storage.setNotificationEnabled(false);
    await cancelDailyReminder();
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelDailyReminder();

    final scheduled = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      id: AppConstants.dailyReminderNotificationId,
      title: AppConstants.notificationTitle,
      body: AppConstants.notificationBody,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.dailyReminderChannelId,
          AppConstants.dailyReminderChannelName,
          channelDescription: AppConstants.dailyReminderChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(id: AppConstants.dailyReminderNotificationId);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
