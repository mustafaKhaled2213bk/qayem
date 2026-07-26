import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: controller.skip,
                child: const Text('تخطي'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140.w,
                          height: 140.w,
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.secondary
                                    : AppColors.primary)
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 64.sp,
                            color: isDark
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 36.h),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.neutralGray,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(controller.pages.length, (index) {
                  final selected = controller.currentPage.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: selected ? 22.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: selected
                          ? (isDark ? AppColors.secondary : AppColors.primary)
                          : AppColors.neutralGray.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  );
                }),
              );
            }),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
              child: Obx(() {
                return AppButton(
                  label: controller.isLastPage ? 'ابدأ الآن' : 'التالي',
                  onPressed: controller.next,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
