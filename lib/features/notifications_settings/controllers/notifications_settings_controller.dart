import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_snackbar.dart';

class NotificationsSettingsController extends GetxController {
  final _storage = Get.find<StorageService>();
  final _notifications = Get.find<NotificationService>();

  final enabled = false.obs;
  final hour = 20.obs;
  final minute = 0.obs;
  final isSaving = false.obs;

  String get timeLabel {
    final h = hour.value.toString().padLeft(2, '0');
    final m = minute.value.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void onInit() {
    super.onInit();
    enabled.value = _storage.notificationEnabled;
    hour.value = _storage.dailyReminderHour;
    minute.value = _storage.dailyReminderMinute;
  }

  Future<void> toggle(bool value) async {
    if (value) {
      await _enable();
    } else {
      await _disable();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour.value, minute: minute.value),
      helpText: 'اختر وقت التذكير',
      cancelText: 'إلغاء',
      confirmText: 'حفظ',
    );
    if (selected == null) return;

    hour.value = selected.hour;
    minute.value = selected.minute;
    await _storage.setDailyReminderTime(hour.value, minute.value);

    if (enabled.value) {
      await _notifications.scheduleDailyReminder(
        hour: hour.value,
        minute: minute.value,
      );
      AppSnackbar.success('تم', 'تم تحديث وقت التذكير');
    }
  }

  Future<void> _enable() async {
    try {
      isSaving.value = true;
      await _notifications.enableDailyReminder(
        hour: hour.value,
        minute: minute.value,
      );
      enabled.value = true;
      AppSnackbar.success('تم', 'تم تفعيل التذكير اليومي');
    } on AppException catch (e) {
      enabled.value = false;
      AppSnackbar.error('خطأ', e.message);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _disable() async {
    try {
      isSaving.value = true;
      await _notifications.disableDailyReminder();
      enabled.value = false;
      AppSnackbar.success('تم', 'تم إيقاف التذكير اليومي');
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    } finally {
      isSaving.value = false;
    }
  }
}
