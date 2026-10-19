import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../app/routes/app_routes.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

typedef NotificationTapHandler = void Function(int bookId);

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int? _pendingBookId;
  NotificationTapHandler? onNotificationTap;

  int? get pendingBookId => _pendingBookId;

  int? takePendingBookId() {
    final id = _pendingBookId;
    _pendingBookId = null;
    return id;
  }

  static int notificationIdForBook(int bookId, [int dayOffset = 0]) =>
      AppConstants.bookReminderNotificationIdBase +
      (bookId * AppConstants.reminderIdStride) +
      dayOffset;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

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

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _handlePayload(launch!.notificationResponse?.payload);
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        _handlePayload(response.payload);
      },
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.dailyReminderChannelId,
        AppConstants.dailyReminderChannelName,
        description: AppConstants.dailyReminderChannelDescription,
        importance: Importance.high,
      ),
    );

    // Cancel legacy global daily reminder.
    await _plugin.cancel(id: AppConstants.legacyDailyReminderNotificationId);

    _initialized = true;
  }

  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final bookId = int.tryParse(payload);
    if (bookId == null) return;

    final handler = onNotificationTap;
    if (handler != null) {
      handler(bookId);
      return;
    }

    if (Get.key.currentState != null) {
      Get.toNamed(AppRoutes.reader, arguments: bookId);
    } else {
      _pendingBookId = bookId;
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (!status.isGranted) return false;
      // Exact alarms are a separate Android 12+ permission.
      await _ensureExactAlarmPermission();
    } else if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      if (!granted) return false;
    }
    return true;
  }

  Future<void> ensurePermission() async {
    final granted = await requestPermission();
    if (!granted) {
      throw const PermissionException(
        'لم يتم منح إذن الإشعارات. فعّل الإذن من إعدادات الجهاز.',
      );
    }
  }

  Future<void> _ensureExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final canExact = await _android?.canScheduleExactNotifications();
    if (canExact == true) return;

    await _android?.requestExactAlarmsPermission();
    if (await _android?.canScheduleExactNotifications() == true) return;

    final status = await Permission.scheduleExactAlarm.request();
    if (status.isGranted) return;
  }

  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final canExact = await _android?.canScheduleExactNotifications();
    if (canExact == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    await _ensureExactAlarmPermission();
    if (await _android?.canScheduleExactNotifications() == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    // Android 12+ may deny exact alarms; inexact still delivers reminders.
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Schedules one notification per day from [startDay], without date-component
  /// matching. Matching rewrites any future date back to the next clock time,
  /// so a "skip until tomorrow / next week" schedule would still fire today.
  Future<void> scheduleDailyWindow({
    required int bookId,
    required String bookTitle,
    required String body,
    required int hour,
    required int minute,
    required DateTime startDay,
  }) async {
    await cancelBookReminder(bookId);

    final mode = await _resolveScheduleMode();
    final now = tz.TZDateTime.now(tz.local);
    final start = DateTime(startDay.year, startDay.month, startDay.day);

    for (var offset = 0; offset < AppConstants.reminderScheduleHorizonDays; offset++) {
      final day = start.add(Duration(days: offset));
      final scheduled = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        hour,
        minute,
      );
      if (!scheduled.isAfter(now)) continue;

      await _zonedScheduleSafe(
        id: notificationIdForBook(bookId, offset),
        bookId: bookId,
        bookTitle: bookTitle,
        body: body,
        scheduledDate: scheduled,
        mode: mode,
      );
    }
  }

  Future<void> _zonedScheduleSafe({
    required int id,
    required int bookId,
    required String bookTitle,
    required String body,
    required tz.TZDateTime scheduledDate,
    required AndroidScheduleMode mode,
  }) async {
    try {
      await _zonedSchedule(
        id: id,
        bookId: bookId,
        bookTitle: bookTitle,
        body: body,
        scheduledDate: scheduledDate,
        mode: mode,
      );
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted' ||
          mode == AndroidScheduleMode.inexactAllowWhileIdle) {
        rethrow;
      }
      await _zonedSchedule(
        id: id,
        bookId: bookId,
        bookTitle: bookTitle,
        body: body,
        scheduledDate: scheduledDate,
        mode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> _zonedSchedule({
    required int id,
    required int bookId,
    required String bookTitle,
    required String body,
    required tz.TZDateTime scheduledDate,
    required AndroidScheduleMode mode,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: 'حان وقت قراءة «$bookTitle»',
      body: body,
      scheduledDate: scheduledDate,
      payload: bookId.toString(),
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
      androidScheduleMode: mode,
    );
  }

  Future<void> cancelBookReminder(int bookId) async {
    await _plugin.cancel(
      id: AppConstants.bookReminderNotificationIdBase + bookId,
    );
    for (var offset = 0; offset < AppConstants.reminderScheduleHorizonDays; offset++) {
      await _plugin.cancel(id: notificationIdForBook(bookId, offset));
    }
  }

  Future<void> cancelAllBookReminders(Iterable<int> bookIds) async {
    for (final id in bookIds) {
      await cancelBookReminder(id);
    }
  }

}
