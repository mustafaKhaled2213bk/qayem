import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/share_service.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/category_repository.dart';

enum CategoryViewMode { grid, list }

class CategoryDetailsController extends GetxController {
  final _categoryRepo = Get.find<CategoryRepository>();
  final _bookRepo = Get.find<BookRepository>();
  final _shareService = Get.find<ShareService>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final category = Rxn<CategoryModel>();
  final books = <BookModel>[].obs;
  final viewMode = CategoryViewMode.grid.obs;

  late final int categoryId;

  @override
  void onInit() {
    super.onInit();
    categoryId = Get.arguments as int;
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == CategoryViewMode.grid
        ? CategoryViewMode.list
        : CategoryViewMode.grid;
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      category.value = await _categoryRepo.getById(categoryId);
      if (category.value == null) {
        errorMessage.value = 'الصنف غير موجود.';
        return;
      }
      books.assignAll(await _bookRepo.getByCategory(categoryId));
      errorMessage.value = '';
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void openBook(BookModel book) {
    Get.toNamed(AppRoutes.reader, arguments: book.id)?.then((_) => load());
  }

  Future<void> shareBook(BookModel book) async {
    try {
      await _shareService.shareBook(book);
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    } catch (_) {
      AppSnackbar.error('خطأ', 'تعذّرت مشاركة الكتاب.');
    }
  }
}
