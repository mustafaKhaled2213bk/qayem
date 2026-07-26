import 'package:get/get.dart';

import '../../../data/models/library_model.dart';

class KnownLibrariesController extends GetxController {
  List<LibraryModel> get items => KnownLibrariesData.items;

  void showLibraryInfo(LibraryModel library) {
    Get.snackbar(
      library.name,
      'الموقع: ${library.urlHint}\n${library.description}',
      duration: const Duration(seconds: 4),
    );
  }
}
