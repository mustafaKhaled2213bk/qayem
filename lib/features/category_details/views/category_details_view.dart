import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/widgets/book_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../controllers/category_details_controller.dart';

class CategoryDetailsView extends GetView<CategoryDetailsController> {
  const CategoryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.category.value?.name ?? 'تفاصيل الصنف')),
        actions: [
          Obx(() {
            return IconButton(
              onPressed: controller.toggleViewMode,
              icon: Icon(
                controller.viewMode.value == CategoryViewMode.grid
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return EmptyState(
            title: 'تعذّر التحميل',
            subtitle: controller.errorMessage.value,
            actionLabel: 'إعادة المحاولة',
            onAction: controller.load,
          );
        }

        final category = controller.category.value!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                '${category.bookCount} كتاب',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: controller.books.isEmpty
                  ? const EmptyState(
                      title: 'لا توجد كتب بعد',
                      subtitle: 'أضف كتاباً إلى هذا الصنف من الصفحة الرئيسية',
                      icon: Icons.menu_book_outlined,
                    )
                  : Obx(() {
                      if (controller.viewMode.value == CategoryViewMode.list) {
                        return ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                          itemCount: controller.books.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final book = controller.books[index];
                            return BookCard(
                              book: book,
                              onTap: () => controller.openBook(book),
                            );
                          },
                        );
                      }

                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        itemCount: controller.books.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12.h,
                          crossAxisSpacing: 12.w,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final book = controller.books[index];
                          return BookTile(
                            book: book,
                            onTap: () => controller.openBook(book),
                          );
                        },
                      );
                    }),
            ),
          ],
        );
      }),
    );
  }
}
