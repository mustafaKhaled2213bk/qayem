import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/theme_service.dart';

class MoreController extends GetxController {
  final themeService = Get.find<ThemeService>();

  void openThemePicker() {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('المظهر')),
            ...ThemeMode.values.map((mode) {
              return Obx(() {
                final selected = themeService.themeMode.value == mode;
                return ListTile(
                  title: Text(themeService.labelFor(mode)),
                  trailing: selected
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    themeService.setThemeMode(mode);
                    Get.back();
                  },
                );
              });
            }),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );
  }

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
