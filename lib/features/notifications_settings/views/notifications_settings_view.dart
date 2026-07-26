import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../controllers/notifications_settings_controller.dart';

class NotificationsSettingsView
    extends GetView<NotificationsSettingsController> {
  const NotificationsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات التنبيهات')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'التذكير اليومي بالقراءة',
            style: AppTextStyles.title,
          ),
          SizedBox(height: 8.h),
          Text(
            'سنرسل لك إشعاراً يومياً لتشجيعك على مواصلة القراءة.',
            style: AppTextStyles.body,
          ),
          SizedBox(height: 20.h),
          Obx(() {
            return SwitchListTile(
              title: const Text('تفعيل التذكير'),
              value: controller.enabled.value,
              onChanged: controller.isSaving.value ? null : controller.toggle,
            );
          }),
          Obx(() {
            return ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: const Text('وقت التذكير'),
              subtitle: Text(controller.timeLabel),
              onTap: () => controller.pickTime(context),
            );
          }),
        ],
      ),
    );
  }
}
