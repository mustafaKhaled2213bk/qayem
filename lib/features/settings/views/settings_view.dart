import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text('التفضيلات', style: AppTextStyles.subtitle),
          SizedBox(height: 8.h),
          Obx(() {
            return ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('المظهر'),
              subtitle: Text(
                controller.themeService
                    .labelFor(controller.themeService.themeMode.value),
              ),
              onTap: controller.openThemePicker,
            );
          }),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('التنبيهات'),
            subtitle: const Text('التذكير اليومي بالقراءة'),
            onTap: controller.openNotifications,
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('تفضيلات القراءة'),
            subtitle: const Text('يتم حفظ آخر صفحة تلقائياً'),
            onTap: () => Get.snackbar(
              'معلومة',
              'يتم حفظ تقدم القراءة تلقائياً أثناء التصفح.',
            ),
          ),
          SizedBox(height: 16.h),
          Text('البيانات', style: AppTextStyles.subtitle),
          SizedBox(height: 8.h),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('مسح سجل القراءة'),
            onTap: controller.clearHistory,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text('مسح كل الكتب', style: TextStyle(color: Colors.red)),
            onTap: controller.clearAllBooks,
          ),
          SizedBox(height: 16.h),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('حول التطبيق'),
            onTap: controller.openAbout,
          ),
        ],
      ),
    );
  }
}
