import 'package:get/get.dart';

import '../../categories/controllers/categories_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../more/controllers/more_controller.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CategoriesController>(() => CategoriesController());
    Get.lazyPut<MoreController>(() => MoreController());
  }
}
