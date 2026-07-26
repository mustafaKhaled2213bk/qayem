import 'package:get/get.dart';

import '../controllers/quotes_controller.dart';

class QuotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuotesController>(() => QuotesController());
  }
}
