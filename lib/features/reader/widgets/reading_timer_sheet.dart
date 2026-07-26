import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_container.dart';
import '../controllers/reader_controller.dart';

class ReadingTimerSheet extends GetView<ReaderController> {
  const ReadingTimerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      child: GlassContainer(
        borderRadius: 28.r,
        thickness: 14,
        blur: 12,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('مؤقت القراءة', style: AppTextStyles.title),
            SizedBox(height: 8.h),
            Text(
              'الوقت المقضي',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.neutralGray,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              return Text(
                DateFormatter.formatTimer(controller.elapsedSeconds.value),
                style: AppTextStyles.displayMedium.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              );
            }),
            SizedBox(height: 8.h),
            Obx(() {
              final label = switch (controller.timerState.value) {
                TimerState.idle => 'جاهز للبدء',
                TimerState.running => 'قيد التشغيل',
                TimerState.paused => 'متوقف مؤقتاً',
                TimerState.stopped => 'متوقف',
              };
              return Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondary,
                ),
              );
            }),
            SizedBox(height: 20.h),
            Obx(() {
              final state = controller.timerState.value;
              return Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                alignment: WrapAlignment.center,
                children: [
                  if (state != TimerState.running)
                    _TimerAction(
                      icon: Icons.play_arrow_rounded,
                      label: 'بدء',
                      onTap: controller.startTimer,
                    ),
                  if (state == TimerState.running)
                    _TimerAction(
                      icon: Icons.pause_rounded,
                      label: 'إيقاف مؤقت',
                      onTap: controller.pauseTimer,
                    ),
                  _TimerAction(
                    icon: Icons.stop_rounded,
                    label: 'إيقاف',
                    onTap: controller.stopTimer,
                  ),
                  _TimerAction(
                    icon: Icons.refresh_rounded,
                    label: 'إعادة',
                    onTap: controller.resetTimer,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TimerAction extends StatelessWidget {
  const _TimerAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 88.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.secondary : AppColors.primary)
              .withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
            SizedBox(height: 4.h),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
