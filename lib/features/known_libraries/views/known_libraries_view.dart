import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/known_libraries_controller.dart';

class KnownLibrariesView extends GetView<KnownLibrariesController> {
  const KnownLibrariesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('مكتبات إلكترونية معروفة')),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.items.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.title),
                SizedBox(height: 6.h),
                Text(item.description, style: AppTextStyles.body),
                SizedBox(height: 6.h),
                Text(
                  item.urlHint,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neutralGray,
                  ),
                ),
                SizedBox(height: 12.h),
                AppButton(
                  label: 'عرض',
                  expand: false,
                  onPressed: () => controller.showLibraryInfo(item),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
