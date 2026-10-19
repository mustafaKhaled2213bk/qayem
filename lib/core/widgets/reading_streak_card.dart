import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class ReadingStreakCard extends StatelessWidget {
  const ReadingStreakCard({
    super.key,
    required this.days,
    required this.readToday,
  });

  final int days;
  final bool readToday;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = days > 0;
    final accent = active
        ? const Color(0xFFE07A2F)
        : (isDark ? AppColors.secondary : AppColors.primary);

    final caption = days == 0
        ? 'ابدأ اليوم'
        : readToday
        ? 'قرأت اليوم'
        : 'اقرأ اليوم';

    return SizedBox(
      width: 108.w,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: isDark ? AppColors.cardDark : AppColors.white,
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.35 : 0.2),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  active
                      ? Icons.local_fire_department_rounded
                      : Icons.local_fire_department_outlined,
                  color: accent,
                  size: 22.sp,
                ),
                SizedBox(height: 6.h),
                Text(
                  '$days',
                  style: AppTextStyles.title.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  days == 1 ? 'يوم' : 'أيام',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutralGray,
                    fontSize: 10.sp,
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
