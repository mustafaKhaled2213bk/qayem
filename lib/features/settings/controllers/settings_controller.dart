import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/pdf_cover_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/repositories/book_repository.dart';
import '../../home/controllers/home_controller.dart';

class SettingsController extends GetxController {
  final themeService = Get.find<ThemeService>();
  final _bookRepo = Get.find<BookRepository>();
  final _coverService = Get.find<PdfCoverService>();

  void openThemePicker() {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return Obx(() {
              return ListTile(
                title: Text(themeService.labelFor(mode)),
                trailing: themeService.themeMode.value == mode
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  themeService.setThemeMode(mode);
                  Get.back();
                },
              );
            });
          }).toList(),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );
  }

  void openFontPicker() {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('نوع الخط')),
            ...AppFontFamily.values.map((font) {
              return Obx(() {
                final selected = themeService.fontFamily.value == font;
                return ListTile(
                  title: Text(
                    themeService.labelForFont(font),
                    style: TextStyle(fontFamily: font.familyName),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    themeService.setFontFamily(font);
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

  void openNotifications() => Get.toNamed(AppRoutes.notificationsSettings);

  Future<void> clearHistory() async {
    final confirmed = await AppDialog.confirm(
      title: 'مسح سجل القراءة',
      message:
          'سيتم إعادة تعيين تقدم القراءة وأوقات الجلسات دون حذف الكتب. هل تريد المتابعة؟',
      confirmLabel: 'مسح السجل',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await _bookRepo.clearHistory();
      _refreshHome();
      AppSnackbar.success('تم', 'تم مسح سجل القراءة');
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    }
  }

  Future<void> clearAllBooks() async {
    final confirmed = await AppDialog.confirm(
      title: 'مسح كل الكتب',
      message: 'سيتم حذف جميع الكتب وجلسات القراءة نهائياً. هل أنت متأكد؟',
      confirmLabel: 'حذف الكل',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await _bookRepo.clearAll();
      await _coverService.clearAllCovers();
      _refreshHome();
      AppSnackbar.success('تم', 'تم حذف جميع الكتب');
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    }
  }

  void openAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('حول التطبيق'),
        content: const Text(
          'قيّم\nرفيقك في رحلة القراءة\nالإصدار 1.0.0',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('حسناً')),
        ],
      ),
    );
  }

  void _refreshHome() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().load();
    }
  }
}
