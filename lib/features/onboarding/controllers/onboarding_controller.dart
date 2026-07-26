import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../data/onboarding_page_data.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  List<OnboardingPageData> get pages => OnboardingPageData.pages;

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (isLastPage) {
      complete();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void skip() => complete();

  Future<void> complete() async {
    await Get.find<StorageService>().setOnboardingCompleted(true);
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
