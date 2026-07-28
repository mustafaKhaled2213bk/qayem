import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/quote_model.dart';

class QuoteEditResult {
  const QuoteEditResult({
    required this.content,
    required this.pageNumber,
  });

  final String content;
  final int pageNumber;
}

class EditQuoteDialog extends StatefulWidget {
  const EditQuoteDialog({
    super.key,
    required this.quote,
    this.title = 'تعديل الاقتباس',
    this.confirmLabel = 'حفظ',
  });

  final QuoteModel quote;
  final String title;
  final String confirmLabel;

  @override
  State<EditQuoteDialog> createState() => _EditQuoteDialogState();
}

class _EditQuoteDialogState extends State<EditQuoteDialog> {
  late final TextEditingController _contentController;
  late final TextEditingController _pageController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.quote.content);
    _pageController =
        TextEditingController(text: '${widget.quote.pageNumber}');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Get.back(
      result: QuoteEditResult(
        content: _contentController.text.trim(),
        pageNumber: int.parse(_pageController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.quote.bookTitle ?? 'كتاب',
                style: AppTextStyles.caption,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _contentController,
                autofocus: true,
                maxLines: 6,
                minLines: 4,
                textAlign: TextAlign.right,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'نص الاقتباس',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'لا يمكن ترك الاقتباس فارغاً';
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'رقم الصفحة',
                ),
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  if (raw.isEmpty) return 'يرجى إدخال رقم الصفحة';
                  final page = int.tryParse(raw);
                  if (page == null || page < 1) {
                    return 'رقم الصفحة غير صالح';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          label: 'إلغاء',
          variant: AppButtonVariant.text,
          expand: false,
          onPressed: () => Get.back(),
        ),
        AppButton(
          label: widget.confirmLabel,
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}
