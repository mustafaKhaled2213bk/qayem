import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_container.dart';
import '../controllers/reading_timer_controller.dart';

class ReadingTimerView extends GetView<ReadingTimerController> {
  const ReadingTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مؤقت القراءة')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: GlassContainer(
            borderRadius: 28.r,
            thickness: 14,
            blur: 12,
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('الوقت المقضي', style: AppTextStyles.subtitle),
                SizedBox(height: 12.h),
                Obx(() {
                  return Text(
                    DateFormatter.formatTimer(controller.elapsedSeconds.value),
                    style: AppTextStyles.displayLarge,
                  );
                }),
                SizedBox(height: 24.h),
                Obx(() {
                  final state = controller.timerState.value;
                  return Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    alignment: WrapAlignment.center,
                    children: [
                      if (state != StandaloneTimerState.running)
                        _ActionChip(
                          label: 'بدء',
                          icon: Icons.play_arrow_rounded,
                          onTap: controller.start,
                        ),
                      if (state == StandaloneTimerState.running)
                        _ActionChip(
                          label: 'إيقاف مؤقت',
                          icon: Icons.pause_rounded,
                          onTap: controller.pause,
                        ),
                      _ActionChip(
                        label: 'إيقاف',
                        icon: Icons.stop_rounded,
                        onTap: controller.stop,
                      ),
                      _ActionChip(
                        label: 'إعادة',
                        icon: Icons.refresh_rounded,
                        onTap: controller.reset,
                      ),
                    ],
                  );
                }),
                SizedBox(height: 16.h),
                Text(
                  'نصيحة: يمكنك أيضاً فتح المؤقت بالضغط المطوّل داخل قارئ PDF.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutralGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18.sp),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
