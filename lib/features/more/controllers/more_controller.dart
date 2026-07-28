import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

class MoreController extends GetxController {
  void openReadBooks() => Get.toNamed(AppRoutes.readBooks);
  void openQuotes() => Get.toNamed(AppRoutes.quotes);
  void openRecommendations() => Get.toNamed(AppRoutes.recommendations);
  void openKnownLibraries() => Get.toNamed(AppRoutes.knownLibraries);
  void openNotifications() => Get.toNamed(AppRoutes.notificationsSettings);
  void openReadingTimer() => Get.toNamed(AppRoutes.readingTimer);
  void openStatistics() => Get.toNamed(AppRoutes.statistics);
  void openSettings() => Get.toNamed(AppRoutes.settings);

  void openAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('حول التطبيق'),
        content: const Text(
          'قيّم\nرفيقك في رحلة القراءة\n\nتطبيق عربي لإدارة وقراءة كتب PDF محلياً مع تتبع التقدم ومؤقت القراءة والتذكيرات اليومية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
