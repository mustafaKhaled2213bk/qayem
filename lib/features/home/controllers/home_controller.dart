import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/pdf_cover_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../widgets/book_title_dialog.dart';
import '../widgets/category_picker_sheet.dart';

enum ViewState { loading, success, empty, error }

class HomeController extends GetxController {
  final _bookRepo = Get.find<BookRepository>();
  final _categoryRepo = Get.find<CategoryRepository>();
  final _fileService = Get.find<FileService>();
  final _coverService = Get.find<PdfCoverService>();
  final _shareService = Get.find<ShareService>();

  final state = ViewState.loading.obs;
  final errorMessage = ''.obs;
  final recentBooks = <BookModel>[].obs;
  final featuredCategories = <CategoryModel>[].obs;
  final searchQuery = ''.obs;
  final searchResults = <BookModel>[].obs;
  final isUploading = false.obs;

  String get greeting => DateFormatter.greetingForNow();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    try {
      state.value = ViewState.loading;
      final books = await _bookRepo.getRecent(
        limit: AppConstants.recentBooksLimit,
      );
      final categories = await _categoryRepo.getAll();
      recentBooks.assignAll(books);
      featuredCategories.assignAll(
        categories.take(AppConstants.featuredCategoriesLimit).toList(),
      );
      state.value = ViewState.success;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      state.value = ViewState.error;
    } catch (_) {
      errorMessage.value = 'حدث خطأ غير متوقع.';
      state.value = ViewState.error;
    }
  }

  Future<void> onSearch(String query) async {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    try {
      searchResults.assignAll(await _bookRepo.search(query));
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
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

  void openCategory(CategoryModel category) {
    Get.toNamed(
      AppRoutes.categoryDetails,
      arguments: category.id,
    )?.then((_) => load());
  }

  void openSettings() => Get.toNamed(AppRoutes.settings);

  Future<void> addBook() async {
    try {
      isUploading.value = true;
      final picked = await _fileService.pickPdf();
      if (picked == null) return;

      final editedTitle = await Get.dialog<String>(
        BookTitleDialog(
          initialTitle: picked.title,
          fileName: picked.fileName,
        ),
        barrierDismissible: false,
      );
      if (editedTitle == null || editedTitle.trim().isEmpty) return;

      final bookTitle = editedTitle.trim();

      final categories = await _categoryRepo.getAll();
      final selected = await AppBottomSheet.show<CategoryModel>(
        title: 'اختر الصنف',
        useGlass: true,
        child: CategoryPickerSheet(
          categories: categories,
          onCreateCategory: _createCategoryFlow,
        ),
      );

      if (selected == null) return;

      final savedPath = await _fileService.persistPdf(
        picked.sourcePath,
        title: bookTitle,
      );

      final coverPath = await _coverService.generateCover(
        savedPath,
        preferredName: bookTitle.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_'),
      );

      final book = await _bookRepo.create(
        title: bookTitle,
        filePath: savedPath,
        categoryId: selected.id,
        coverPath: coverPath,
      );

      AppSnackbar.success('تم', 'تمت إضافة الكتاب بنجاح');
      await load();
      openBook(book);
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    } catch (_) {
      AppSnackbar.error('خطأ', 'تعذّر إضافة الكتاب.');
    } finally {
      isUploading.value = false;
    }
  }

  Future<CategoryModel?> _createCategoryFlow() async {
    final draft = await Get.dialog<CategoryDraft>(
      const CreateCategoryDialog(),
    );
    if (draft == null) return null;

    final created = await _categoryRepo.create(
      name: draft.name,
      icon: draft.icon,
      colorValue: draft.colorValue,
    );
    return created;
  }
}
