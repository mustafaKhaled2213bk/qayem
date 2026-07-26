import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/book_model.dart';
import '../utils/date_formatter.dart';
import 'app_progress_bar.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onContinue,
    this.onShare,
  });

  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback? onContinue;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = book.categoryColor != null
        ? Color(book.categoryColor!)
        : AppColors.primary;

    return Material(
      color: isDark ? AppColors.cardDark : AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.neutralGray.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              _Cover(title: book.title, color: categoryColor),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      book.categoryName ?? 'بدون صنف',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutralGray,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    AppProgressBar(progress: book.progress),
                    SizedBox(height: 6.h),
                    Text(
                      'آخر فتح: ${DateFormatter.formatDate(book.lastOpenedAt)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neutralGray,
                      ),
                    ),
                    if (onContinue != null || onShare != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          if (onContinue != null)
                            TextButton(
                              onPressed: onContinue,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('متابعة القراءة'),
                            ),
                          const Spacer(),
                          if (onShare != null)
                            IconButton(
                              onPressed: onShare,
                              tooltip: 'مشاركة',
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                Icons.share_outlined,
                                size: 20.sp,
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
    required this.onTap,
    this.onShare,
  });

  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = book.categoryColor != null
        ? Color(book.categoryColor!)
        : AppColors.primary;

    return Material(
      color: isDark ? AppColors.cardDark : AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _Cover(title: book.title, color: categoryColor),
                    ),
                    if (onShare != null)
                      Positioned(
                        top: 4.h,
                        left: 4.w,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(99.r),
                          child: InkWell(
                            onTap: onShare,
                            borderRadius: BorderRadius.circular(99.r),
                            child: Padding(
                              padding: EdgeInsets.all(6.w),
                              child: Icon(
                                Icons.share_outlined,
                                size: 16.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              AppProgressBar(progress: book.progress, height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 96.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color,
            color.withValues(alpha: 0.75),
            AppColors.secondary.withValues(alpha: 0.85),
          ],
        ),
      ),
      padding: EdgeInsets.all(8.w),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Text(
          title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }
}
