import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.goalMinutes,
    required this.todaySeconds,
    this.enabledCount = 0,
    this.onTap,
  });

  final int goalMinutes;
  final int todaySeconds;
  final int enabledCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondary : AppColors.primary;
    final hasGoals = enabledCount > 0 && goalMinutes > 0;

    if (!hasGoals) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: isDark ? AppColors.cardDark : AppColors.white,
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.3 : 0.14),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
              child: Row(
                children: [
                  Icon(Icons.alarm_add_rounded, color: accent, size: 22.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهداف القراءة',
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'اضبط تذكيراً وهدفاً لكل كتاب لتتابع تقدمك',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.neutralGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.neutralGray,
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final goalSeconds = (goalMinutes * 60).clamp(60, 24 * 60 * 60);
    final progress = (todaySeconds / goalSeconds).clamp(0.0, 1.0);
    final todayMinutes = todaySeconds ~/ 60;
    final remainingSeconds = (goalSeconds - todaySeconds).clamp(0, goalSeconds);
    final done = todaySeconds >= goalSeconds;

    final statusText = done
        ? 'أحسنت! حققت هدف اليوم'
        : remainingSeconds >= 60
            ? 'متبقّى ${remainingSeconds ~/ 60} دقيقة عبر $enabledCount تذكير'
            : remainingSeconds > 0
                ? 'متبقّى أقل من دقيقة'
                : 'ابدأ القراءة لتحقيق هدفك';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: isDark ? AppColors.cardDark : AppColors.white,
            border: Border.all(
              color: done
                  ? AppColors.success.withValues(alpha: 0.35)
                  : accent.withValues(alpha: isDark ? 0.3 : 0.14),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      done
                          ? Icons.emoji_events_rounded
                          : Icons.flag_outlined,
                      color: done ? AppColors.success : accent,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'هدف اليوم',
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '$todayMinutes / $goalMinutes د',
                      style: AppTextStyles.caption.copyWith(
                        color: done ? AppColors.success : accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8.h,
                    backgroundColor:
                        AppColors.neutralGray.withValues(alpha: 0.18),
                    color: done ? AppColors.success : accent,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  statusText,
                  style: AppTextStyles.caption.copyWith(
                    color: done
                        ? AppColors.success
                        : AppColors.neutralGray,
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
