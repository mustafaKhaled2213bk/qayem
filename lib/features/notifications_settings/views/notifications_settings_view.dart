import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../data/models/book_reminder_model.dart';
import '../controllers/notifications_settings_controller.dart';

class NotificationsSettingsView
    extends GetView<NotificationsSettingsController> {
  const NotificationsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تذكيرات القراءة')),
      floatingActionButton: Obx(() {
        if (controller.booksWithoutReminder.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: controller.isSaving.value
              ? null
              : controller.pickBookToAdd,
          icon: const Icon(Icons.add_alarm_rounded),
          label: const Text('تذكير لكتاب'),
        );
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState();
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return EmptyState(
            title: 'تعذّر التحميل',
            subtitle: controller.errorMessage.value,
            actionLabel: 'إعادة المحاولة',
            onAction: controller.load,
          );
        }
        if (controller.reminders.isEmpty) {
          return EmptyState(
            title: 'لا توجد تذكيرات بعد',
            subtitle:
                'أضف تذكيراً من بطاقة أي كتاب أو من الزر أدناه لتحديد وقت وهدف القراءة.',
            icon: Icons.alarm_outlined,
            actionLabel: controller.booksWithoutReminder.isEmpty
                ? null
                : 'إضافة تذكير',
            onAction: controller.booksWithoutReminder.isEmpty
                ? null
                : controller.pickBookToAdd,
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          children: [
            Text(
              'تذكير يومي لكل كتاب مع هدف مدة يومي أو أسبوعي',
              style: AppTextStyles.body,
            ),
            SizedBox(height: 16.h),
            ...controller.reminders.map(_ReminderTile.new),
          ],
        );
      }),
    );
  }
}

class _ReminderTile extends GetView<NotificationsSettingsController> {
  const _ReminderTile(this.reminder);

  final BookReminderModel reminder;

  @override
  Widget build(BuildContext context) {
    final title = reminder.bookTitle ?? 'كتاب';
    final periodLabel = reminder.goalPeriod.labelAr;
    final goalLabel = reminder.goalMinutes >= 60 &&
            reminder.goalMinutes % 60 == 0
        ? '${reminder.goalMinutes ~/ 60} ساعة'
        : '${reminder.goalMinutes} دقيقة';

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        leading: Icon(
          reminder.enabled
              ? Icons.alarm_on_rounded
              : Icons.alarm_off_rounded,
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${reminder.timeLabel} · هدف $periodLabel: $goalLabel',
          style: AppTextStyles.caption,
        ),
        trailing: Obx(() {
          return Switch(
            value: reminder.enabled,
            onChanged: controller.isSaving.value
                ? null
                : (value) => controller.toggle(reminder, value),
          );
        }),
        onTap: () => controller.editReminder(reminder),
        onLongPress: () => controller.openBook(reminder),
      ),
    );
  }
}
