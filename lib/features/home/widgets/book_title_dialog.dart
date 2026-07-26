import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class BookTitleDialog extends StatefulWidget {
  const BookTitleDialog({
    super.key,
    required this.initialTitle,
    this.fileName,
  });

  final String initialTitle;
  final String? fileName;

  @override
  State<BookTitleDialog> createState() => _BookTitleDialogState();
}

class _BookTitleDialogState extends State<BookTitleDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Get.back(result: _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اسم الكتاب'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'يمكنك تعديل الاسم الذي سيظهر في مكتبتك.',
              style: AppTextStyles.caption,
            ),
            if (widget.fileName != null) ...[
              SizedBox(height: 8.h),
              Text(
                'الملف: ${widget.fileName}',
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 16.h),
            TextFormField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'اسم الكتاب',
                hintText: 'أدخل اسم الكتاب',
              ),
              validator: (value) {
                final title = value?.trim() ?? '';
                if (title.isEmpty) {
                  return 'يرجى إدخال اسم الكتاب';
                }
                if (title.length < 2) {
                  return 'الاسم قصير جداً';
                }
                return null;
              },
            ),
          ],
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
          label: 'متابعة',
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}
