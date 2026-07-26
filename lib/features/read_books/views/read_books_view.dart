import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/book_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../controllers/read_books_controller.dart';

class ReadBooksView extends GetView<ReadBooksController> {
  const ReadBooksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الكتب المقروءة')),
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
        if (controller.books.isEmpty) {
          return const EmptyState(
            title: 'لا توجد كتب مقروءة',
            subtitle: 'عند إنهاء كتاب سيظهر هنا',
            icon: Icons.done_all_rounded,
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.books.length,
          separatorBuilder: (_, _) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final book = controller.books[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BookCard(
                  book: book,
                  onTap: () => controller.openBook(book),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4.h, right: 8.w, left: 8.w),
                  child: Text(
                    'وقت القراءة: ${DateFormatter.formatDuration(book.totalReadingTime)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
