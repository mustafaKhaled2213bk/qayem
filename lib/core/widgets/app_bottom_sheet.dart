import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_text_styles.dart';
import 'glass_container.dart';

abstract final class AppBottomSheet {
  static Future<T?> show<T>({
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool useGlass = false,
  }) {
    return Get.bottomSheet<T>(
      SafeArea(
        child: useGlass
            ? Padding(
                padding: EdgeInsets.all(12.w),
                child: GlassContainer(
                  borderRadius: 24.r,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  child: _SheetBody(title: title, child: child),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Get.theme.bottomSheetTheme.backgroundColor ??
                      Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: _SheetBody(title: title, child: child),
              ),
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(99.r),
          ),
        ),
        if (title != null) ...[
          SizedBox(height: 12.h),
          Text(title!, style: AppTextStyles.title),
          SizedBox(height: 12.h),
        ] else
          SizedBox(height: 12.h),
        Flexible(child: child),
      ],
    );
  }
}
