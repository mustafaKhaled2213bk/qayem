import 'dart:developer';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    log('onInit>>>>>>>>>>>>>>>>>');
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    log('navigate>>>>>>>>>>>>>>>>>');
    await Future<void>.delayed(
      const Duration(seconds: 2),
    );

    final storage = Get.find<StorageService>();
    if (storage.onboardingCompleted) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
