import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onReady() {
    super.onReady();
    _bindNotificationTaps();
  }

  void changeTab(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }

  void _bindNotificationTaps() {
    if (!Get.isRegistered<NotificationService>()) return;
    final notifications = Get.find<NotificationService>();
    notifications.onNotificationTap = (bookId) {
      Get.toNamed(AppRoutes.reader, arguments: bookId);
    };
    final pending = notifications.takePendingBookId();
    if (pending != null) {
      Future<void>.microtask(() {
        Get.toNamed(AppRoutes.reader, arguments: pending);
      });
    }
  }
}
