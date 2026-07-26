import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/models/category_model.dart';

class CategoryPickerSheet extends StatefulWidget {
  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.onCreateCategory,
  });

  final List<CategoryModel> categories;
  final Future<CategoryModel?> Function() onCreateCategory;

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  late List<CategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.of(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 0.55.sh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: category.color.withValues(alpha: 0.15),
                    child: Icon(category.iconData, color: category.color),
                  ),
                  title: Text(category.name, style: AppTextStyles.subtitle),
                  subtitle: Text('${category.bookCount} كتاب'),
                  onTap: () => Get.back(result: category),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
              child: const Icon(Icons.add, color: AppColors.primary),
            ),
            title: Text(
              'إنشاء صنف جديد',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () async {
              final created = await widget.onCreateCategory();
              if (created == null) return;
              setState(() => _categories = [..._categories, created]);
              Get.back(result: created);
            },
          ),
        ],
      ),
    );
  }
}
