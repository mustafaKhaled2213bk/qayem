import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/glass_container.dart';
import '../controllers/reader_controller.dart';

class ReaderTimerIndicator extends GetView<ReaderController> {
  const ReaderTimerIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.timerState.value;
      final isRunning = state == TimerState.running;
      final isPaused = state == TimerState.paused;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.toggleTimerPanel,
          borderRadius: BorderRadius.circular(99.r),
          child: GlassContainer(
            borderRadius: 99.r,
            thickness: 10,
            blur: 8,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRunning
                      ? Icons.timer_rounded
                      : isPaused
                          ? Icons.pause_circle_outline_rounded
                          : Icons.timer_outlined,
                  size: 18.sp,
                  color: AppColors.secondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  DateFormatter.formatTimer(controller.elapsedSeconds.value),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.backgroundDark,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (isRunning || isPaused) ...[
                  SizedBox(width: 6.w),
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: isRunning ? Colors.greenAccent : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

class ReaderTimerPanel extends GetView<ReaderController> {
  const ReaderTimerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 22.r,
      thickness: 12,
      blur: 10,
      padding: EdgeInsets.all(14.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'مؤقت القراءة',
                  style: AppTextStyles.subtitle.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark? AppColors.white : AppColors.backgroundDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.hideTimerPanel,
                icon:  Icon(Icons.close_rounded, color: Theme.of(context).brightness == Brightness.dark? AppColors.white : AppColors.backgroundDark),
                tooltip: 'إخفاء',
              ),
            ],
          ),
          Obx(() {
            return Text(
              DateFormatter.formatTimer(controller.elapsedSeconds.value),
              style: AppTextStyles.headline.copyWith(
                color: Theme.of(context).brightness == Brightness.dark? AppColors.white : AppColors.backgroundDark,
                letterSpacing: 1.5,
              ),
            );
          }),
          SizedBox(height: 6.h),
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
                color: Theme.of(context).brightness == Brightness.dark? AppColors.white : AppColors.backgroundDark,
              ),
            );
          }),
          SizedBox(height: 14.h),
          Obx(() {
            final state = controller.timerState.value;
            return Row(
              children: [
                if (state != TimerState.running)
                  Expanded(
                    child: _CompactAction(
                      icon: Icons.play_arrow_rounded,
                      label: 'بدء',
                      onTap: controller.startTimer,
                    ),
                  ),
                if (state == TimerState.running)
                  Expanded(
                    child: _CompactAction(
                      icon: Icons.pause_rounded,
                      label: 'إيقاف مؤقت',
                      onTap: controller.pauseTimer,
                    ),
                  ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _CompactAction(
                    icon: Icons.stop_rounded,
                    label: 'إيقاف',
                    onTap: controller.stopTimer,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _CompactAction(
                    icon: Icons.refresh_rounded,
                    label: 'إعادة',
                    onTap: controller.resetTimer,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  const _CompactAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Icon(icon, color:Theme.of(context).brightness == Brightness.dark? Theme.of(context).brightness == Brightness.dark? AppColors.white : AppColors.backgroundDark : AppColors.backgroundDark, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).brightness == Brightness.dark? AppColors.white : AppColors.backgroundDark,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
