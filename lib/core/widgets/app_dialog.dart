import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../data/models/category_model.dart';
import 'app_button.dart';

abstract final class AppDialog {
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    bool isDestructive = false,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<T?> show<T>({
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return Get.dialog<T>(
      AlertDialog(
        title: Text(title),
        content: content,
        actions: actions,
      ),
    );
  }
}

class CreateCategoryDialog extends StatefulWidget {
  const CreateCategoryDialog({
    super.key,
    this.initialName,
    this.initialIcon = 'folder',
    this.initialColor,
  });

  final String? initialName;
  final String initialIcon;
  final int? initialColor;

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  late final TextEditingController _nameController;
  late String _icon;
  late int _color;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _icon = widget.initialIcon;
    _color = widget.initialColor ?? 0xFF042623;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialName == null ? 'إنشاء صنف جديد' : 'تعديل الصنف',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الصنف',
                  hintText: 'مثال: روايات',
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              const Text('اختيار الأيقونة'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryIconKeys.map((key) {
                  final selected = _icon == key;
                  return InkWell(
                    onTap: () => setState(() => _icon = key),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? Color(_color).withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? Color(_color)
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(categoryIconFromKey(key), size: 20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('اختيار اللون'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppColors.categoryPalette.map((color) {
                  final value = color.toARGB32();
                  final selected = _color == value;
                  return GestureDetector(
                    onTap: () => setState(() => _color = value),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
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
          label: 'حفظ',
          expand: false,
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Get.back(
              result: CategoryDraft(
                name: name,
                icon: _icon,
                colorValue: _color,
              ),
            );
          },
        ),
      ],
    );
  }
}

class CategoryDraft {
  const CategoryDraft({
    required this.name,
    required this.icon,
    required this.colorValue,
  });

  final String name;
  final String icon;
  final int colorValue;
}
