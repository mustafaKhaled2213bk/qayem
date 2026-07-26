import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/book_card.dart';
import '../../../core/widgets/category_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/section_header.dart';
import '../controllers/home_controller.dart';
class CustomFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(
      10.w,
      scaffoldGeometry.scaffoldSize.height - 140.h,
    );
  }
}
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(() {
        return FloatingActionButton.extended(
          onPressed: controller.isUploading.value ? null : controller.addBook,
          tooltip: 'إضافة كتاب',
          icon: controller.isUploading.value
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_rounded),
          label: const Text('إضافة كتاب'),
        );
      }),
      floatingActionButtonLocation: CustomFabLocation(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(controller: controller)),
              Obx(() {
                if (controller.searchQuery.value.trim().isNotEmpty) {
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                    sliver: controller.searchResults.isEmpty
                        ? const SliverToBoxAdapter(
                            child: EmptyState(
                              title: 'لا توجد نتائج',
                              subtitle: 'جرّب كلمة بحث أخرى',
                              icon: Icons.search_off_rounded,
                            ),
                          )
                        : SliverList.separated(
                            itemCount: controller.searchResults.length,
                            separatorBuilder: (_, _) => SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              final book = controller.searchResults[index];
                              return BookCard(
                                book: book,
                                onTap: () => controller.openBook(book),
                              );
                            },
                          ),
                  );
                }

                switch (controller.state.value) {
                  case ViewState.loading:
                    return const SliverFillRemaining(
                      child: LoadingState(message: 'جاري التحميل...'),
                    );
                  case ViewState.error:
                    return SliverFillRemaining(
                      child: EmptyState(
                        title: 'تعذّر التحميل',
                        subtitle: controller.errorMessage.value,
                        actionLabel: 'إعادة المحاولة',
                        onAction: controller.load,
                        icon: Icons.error_outline_rounded,
                      ),
                    );
                  case ViewState.empty:
                  case ViewState.success:
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        const SectionHeader(title: 'آخر الكتب المقروءة'),
                        if (controller.recentBooks.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: EmptyState(
                              title: 'لا توجد كتب بعد',
                              subtitle: 'أضف أول كتاب PDF لتبدأ رحلتك',
                              actionLabel: 'إضافة كتاب',
                              onAction: controller.addBook,
                            ),
                          )
                        else
                          ...controller.recentBooks.map(
                            (book) => Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                              child: BookCard(
                                book: book,
                                onTap: () => controller.openBook(book),
                                onContinue: () => controller.openBook(book),
                              ),
                            ),
                          ),
                        const SectionHeader(title: 'أبرز الأصناف'),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.featuredCategories.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,
                              childAspectRatio: 1.15,
                            ),
                            itemBuilder: (context, index) {
                              final category =
                                  controller.featuredCategories[index];
                              return CategoryCard(
                                category: category,
                                onTap: () => controller.openCategory(category),
                              );
                            },
                          ),
                        ),
                      ]),
                    );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.greeting,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutralGray,
                      ),
                    ),
                    Text(
                      'قيّم',
                      style: AppTextStyles.headline.copyWith(
                        color: isDark
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: controller.openSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GlassContainer(
            borderRadius: 16.r,
            thickness: 8,
            blur: 6,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: AppTextField(
              hintText: 'ابحث عن كتاب...',
              prefixIcon: Icons.search_rounded,
              onChanged: controller.onSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
        ],
      ),
    );
  }
}
