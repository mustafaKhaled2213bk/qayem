import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/book_model.dart';
import '../../../data/repositories/book_repository.dart';

class ReadBooksController extends GetxController {
  final _repo = Get.find<BookRepository>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final books = <BookModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      books.assignAll(await _repo.getCompleted());
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
}
