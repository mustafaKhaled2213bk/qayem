import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/quote_model.dart';
import '../controllers/quotes_controller.dart';
import 'quote_image_card.dart';

class QuoteImagePreview extends StatefulWidget {
  const QuoteImagePreview({super.key, required this.quote});

  final QuoteModel quote;

  static Future<void> show(QuoteModel quote) {
    return Get.dialog(
      QuoteImagePreview(quote: quote),
      barrierDismissible: true,
    );
  }

  @override
  State<QuoteImagePreview> createState() => _QuoteImagePreviewState();
}

class _QuoteImagePreviewState extends State<QuoteImagePreview> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      await Get.find<QuotesController>().shareQuoteImage(
        quote: widget.quote,
        boundaryKey: _boundaryKey,
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: QuoteImageCard(quote: widget.quote),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.cardDark
                  : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  'مشاركة الاقتباس كصورة',
                  style: AppTextStyles.subtitle,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'مشاركة',
                        icon: Icons.share_outlined,
                        isLoading: _isSharing,
                        onPressed: _share,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: AppButton(
                        label: 'إغلاق',
                        variant: AppButtonVariant.outline,
                        onPressed: Get.back,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
