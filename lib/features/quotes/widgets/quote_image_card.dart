import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/quote_model.dart';

/// Visual card used for quote image export.
/// Wrap with [RepaintBoundary] via [QuoteImageCard.boundary].
class QuoteImageCard extends StatelessWidget {
  const QuoteImageCard({
    super.key,
    required this.quote,
    this.width = 360,
    this.height = 480,
  });

  final QuoteModel quote;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bookName = quote.bookTitle ?? 'كتاب';

    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.secondary,
            size: 36,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                quote.content,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: AppFonts.active,
                  color: AppColors.secondary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.7,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            bookName,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.active,
              color: AppColors.secondary.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'صفحة ${quote.pageNumber}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: AppFonts.active,
              color: AppColors.secondary.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'assets/images/logo-removebg-preview.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.menu_book_rounded,
              color: AppColors.secondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontFamily: AppFonts.active,
              color: AppColors.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
