import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.showLabel = true,
    this.height,
  });

  final double progress;
  final bool showLabel;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    final percent = (value * 100).round();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: LinearProgressIndicator(
              value: value,
              minHeight: height ?? 6.h,
              backgroundColor: AppColors.neutralGray.withValues(alpha: 0.2),
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ),
        ),
        if (showLabel) ...[
          SizedBox(width: 8.w),
          Text(
            '$percent%',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}
