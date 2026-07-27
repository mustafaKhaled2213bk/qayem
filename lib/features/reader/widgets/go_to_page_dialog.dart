import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class GoToPageDialog extends StatefulWidget {
  const GoToPageDialog({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  State<GoToPageDialog> createState() => _GoToPageDialogState();
}

class _GoToPageDialogState extends State<GoToPageDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.currentPage}');
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
    final page = int.parse(_controller.text.trim());
    Get.back(result: page);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('الانتقال إلى صفحة'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أدخل رقم الصفحة بين 1 و ${widget.totalPages}',
              style: AppTextStyles.caption,
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'رقم الصفحة',
                hintText: 'مثال: 12',
              ),
              validator: (value) {
                final raw = value?.trim() ?? '';
                if (raw.isEmpty) return 'يرجى إدخال رقم الصفحة';
                final page = int.tryParse(raw);
                if (page == null) return 'رقم غير صالح';
                if (page < 1 || page > widget.totalPages) {
                  return 'الصفحة يجب أن تكون بين 1 و ${widget.totalPages}';
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
          label: 'انتقال',
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}
