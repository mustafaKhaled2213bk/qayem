import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/category_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../controllers/categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأصناف', style: AppTextStyles.title.copyWith(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState(message: 'جاري تحميل الأصناف...');
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.categories.isEmpty) {
          return EmptyState(
            title: 'تعذّر التحميل',
            subtitle: controller.errorMessage.value,
            actionLabel: 'إعادة المحاولة',
            onAction: controller.load,
            icon: Icons.error_outline_rounded,
          );
        }

        final itemCount = controller.categories.length + 1;

        return RefreshIndicator(
          onRefresh: controller.load,
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              if (index == controller.categories.length) {
                return AddCategoryCard(onTap: controller.createCategory);
              }
              final category = controller.categories[index];
              return CategoryCard(
                category: category,
                onTap: () => controller.openCategory(category),
                onLongPress: () => controller.onLongPress(category),
              );
            },
          ),
        );
      }),
    );
  }
}
