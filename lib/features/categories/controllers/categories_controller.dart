import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../home/controllers/home_controller.dart';

class CategoriesController extends GetxController {
  final _repo = Get.find<CategoryRepository>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final categories = <CategoryModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      categories.assignAll(await _repo.getAll());
      errorMessage.value = '';
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void openCategory(CategoryModel category) {
    Get.toNamed(
      AppRoutes.categoryDetails,
      arguments: category.id,
    )?.then((_) => load());
  }

  Future<void> createCategory() async {
    final draft = await Get.dialog<CategoryDraft>(
      const CreateCategoryDialog(),
    );
    if (draft == null) return;

    try {
      await _repo.create(
        name: draft.name,
        icon: draft.icon,
        colorValue: draft.colorValue,
      );
      await load();
      _refreshHome();
      AppSnackbar.success('تم', 'تم إنشاء الصنف بنجاح');
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    }
  }

  Future<void> onLongPress(CategoryModel category) async {
    final action = await Get.bottomSheet<String>(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('تعديل'),
              onTap: () => Get.back(result: 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () => Get.back(result: 'delete'),
            ),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );

    if (action == 'edit') {
      await _edit(category);
    } else if (action == 'delete') {
      await _delete(category);
    }
  }

  Future<void> _edit(CategoryModel category) async {
    final draft = await Get.dialog<CategoryDraft>(
      CreateCategoryDialog(
        initialName: category.name,
        initialIcon: category.icon,
        initialColor: category.colorValue,
      ),
    );
    if (draft == null) return;

    try {
      await _repo.update(
        category.copyWith(
          name: draft.name,
          icon: draft.icon,
          colorValue: draft.colorValue,
        ),
      );
      await load();
      _refreshHome();
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    }
  }

  Future<void> _delete(CategoryModel category) async {
    final confirmed = await AppDialog.confirm(
      title: 'حذف الصنف',
      message: 'هل أنت متأكد من حذف "${category.name}"؟',
      confirmLabel: 'حذف',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await _repo.delete(category.id);
      await load();
      _refreshHome();
      AppSnackbar.success('تم', 'تم حذف الصنف');
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    }
  }

  void _refreshHome() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().load();
    }
  }
}
