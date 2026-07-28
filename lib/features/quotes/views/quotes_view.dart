import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../data/models/quote_model.dart';
import '../controllers/quotes_controller.dart';

class QuotesView extends GetView<QuotesController> {
  const QuotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اقتباساتي')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState(message: 'جاري تحميل الاقتباسات...');
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return EmptyState(
            title: 'تعذّر التحميل',
            subtitle: controller.errorMessage.value,
            actionLabel: 'إعادة المحاولة',
            onAction: controller.load,
            icon: Icons.error_outline_rounded,
          );
        }

        if (controller.quotes.isEmpty) {
          return const EmptyState(
            title: 'لا توجد اقتباسات بعد',
            subtitle:
                'حدّد نصاً أثناء القراءة ثم اضغط «اقتباس» لحفظه هنا',
            icon: Icons.format_quote_rounded,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.quotes.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final quote = controller.quotes[index];
              return _QuoteCard(
                quote: quote,
                onTap: () => controller.openQuoteImage(quote),
                onEdit: () => controller.editQuote(quote),
                onDelete: () => controller.deleteQuote(quote),
                onShare: () => controller.openQuoteImage(quote),
                onOpen: () => controller.openInBook(quote),
              );
            },
          ),
        );
      }),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onOpen,
  });

  final QuoteModel quote;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.cardDark : AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      quote.bookTitle ?? 'كتاب',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                  Icon(
                    Icons.image_outlined,
                    size: 18.sp,
                    color: AppColors.neutralGray,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                quote.content,
                style: AppTextStyles.body.copyWith(height: 1.6),
              ),
              SizedBox(height: 10.h),
              Text(
                'صفحة ${quote.pageNumber} • ${DateFormatter.formatDate(quote.createdAt)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutralGray,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: const Text('عرض في الكتاب'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    tooltip: 'تعديل',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'عرض الصورة ومشاركتها',
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined),
                  ),
                  IconButton(
                    tooltip: 'حذف',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
