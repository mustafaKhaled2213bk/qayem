import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_bottom_navigation.dart';
import '../../categories/views/categories_view.dart';
import '../../home/views/home_view.dart';
import '../../more/views/more_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() {
        return IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            CategoriesView(),
            MoreView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return AppBottomNavigation(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        );
      }),
    );
  }
}
