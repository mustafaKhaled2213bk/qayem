import 'package:get/get.dart';

import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/library_model.dart';

class KnownLibrariesController extends GetxController {
  List<LibraryModel> get items => KnownLibrariesData.items;

  void showLibraryInfo(LibraryModel library) {
    AppSnackbar.show(
      title: library.name,
      message: 'الموقع: ${library.urlHint}\n${library.description}',
      duration: const Duration(seconds: 4),
    );
  }
}
