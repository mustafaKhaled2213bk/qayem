import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/book_model.dart';
import 'app_progress_bar.dart';
import 'book_card.dart';

class ContinueReadingBanner extends StatelessWidget {
  const ContinueReadingBanner({
    super.key,
    required this.book,
    required this.onContinue,
  });

  final BookModel book;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondary : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onContinue,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                accent.withValues(alpha: isDark ? 0.28 : 0.12),
                accent.withValues(alpha: isDark ? 0.1 : 0.04),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.35 : 0.18),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                BookCover(
                  book: book,
                  width: 64.w,
                  height: 88.h,
                  borderRadius: 10.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'متابعة القراءة',
                        style: AppTextStyles.caption.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        book.totalPages > 0
                            ? 'توقفت عند صفحة ${book.currentPage} من ${book.totalPages}'
                            : 'توقفت عند صفحة ${book.currentPage}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutralGray,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      AppProgressBar(
                        progress: book.progress,
                        height: 5.h,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: accent,
                  size: 36.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
