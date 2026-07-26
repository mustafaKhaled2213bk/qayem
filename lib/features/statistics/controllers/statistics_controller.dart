import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/book_repository.dart';

class StatisticsController extends GetxController {
  final _repo = Get.find<BookRepository>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final stats = Rxn<ReadingStats>();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      stats.value = await _repo.getStats();
      errorMessage.value = '';
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
