import 'package:get/get.dart';

import '../controllers/read_books_controller.dart';

class ReadBooksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReadBooksController>(() => ReadBooksController());
  }
}
