import 'package:get/get.dart';

import '../controllers/reading_timer_controller.dart';

class ReadingTimerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReadingTimerController>(() => ReadingTimerController());
  }
}
