import 'package:get/get.dart';

import '../controllers/known_libraries_controller.dart';

class KnownLibrariesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KnownLibrariesController>(() => KnownLibrariesController());
  }
}
