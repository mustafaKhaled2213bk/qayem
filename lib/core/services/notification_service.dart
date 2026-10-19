import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../app/routes/app_routes.dart';
import '../../data/models/book_reminder_model.dart';
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

  static int notificationIdForBook(int bookId) =>
      AppConstants.bookReminderNotificationIdBase + bookId;

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

  Future<void> scheduleBookReminder({
    required BookReminderModel reminder,
    required String bookTitle,
    required String body,
  }) async {
    await cancelBookReminder(reminder.bookId);

    if (!reminder.enabled) return;

    final scheduled = _nextInstanceOfTime(reminder.hour, reminder.minute);
    await _zonedScheduleSafe(
      bookId: reminder.bookId,
      bookTitle: bookTitle,
      body: body,
      scheduledDate: scheduled,
    );
  }

  /// Schedules the next fire after [after], still at the reminder clock time.
  Future<void> scheduleBookReminderAfter({
    required BookReminderModel reminder,
    required String bookTitle,
    required String body,
    required DateTime after,
  }) async {
    await cancelBookReminder(reminder.bookId);
    if (!reminder.enabled) return;

    var scheduled = tz.TZDateTime(
      tz.local,
      after.year,
      after.month,
      after.day,
      reminder.hour,
      reminder.minute,
    );
    if (!scheduled.isAfter(tz.TZDateTime.from(after, tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _zonedScheduleSafe(
      bookId: reminder.bookId,
      bookTitle: bookTitle,
      body: body,
      scheduledDate: scheduled,
    );
  }

  Future<void> _zonedScheduleSafe({
    required int bookId,
    required String bookTitle,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    final mode = await _resolveScheduleMode();
    try {
      await _zonedSchedule(
        bookId: bookId,
        bookTitle: bookTitle,
        body: body,
        scheduledDate: scheduledDate,
        mode: mode,
      );
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') rethrow;
      // Last resort: retry without exact alarms.
      await _zonedSchedule(
        bookId: bookId,
        bookTitle: bookTitle,
        body: body,
        scheduledDate: scheduledDate,
        mode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> _zonedSchedule({
    required int bookId,
    required String bookTitle,
    required String body,
    required tz.TZDateTime scheduledDate,
    required AndroidScheduleMode mode,
  }) {
    return _plugin.zonedSchedule(
      id: notificationIdForBook(bookId),
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
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelBookReminder(int bookId) async {
    await _plugin.cancel(id: notificationIdForBook(bookId));
  }

  Future<void> cancelAllBookReminders(Iterable<int> bookIds) async {
    for (final id in bookIds) {
      await cancelBookReminder(id);
    }
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
