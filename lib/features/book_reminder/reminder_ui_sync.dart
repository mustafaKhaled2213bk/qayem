import 'package:get/get.dart';

import '../../core/services/reading_reminder_service.dart';
import '../home/controllers/home_controller.dart';
import '../notifications_settings/controllers/notifications_settings_controller.dart';

/// Refreshes screens that depend on book reminders after create/update/delete.
abstract final class ReminderUiSync {
  static Future<void> refresh() async {
    if (Get.isRegistered<ReadingReminderService>()) {
      await Get.find<ReadingReminderService>().refreshBookIds();
    }
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().load(silent: true);
    }
    if (Get.isRegistered<NotificationsSettingsController>()) {
      await Get.find<NotificationsSettingsController>().load(silent: true);
    }
  }
}
