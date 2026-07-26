import 'package:get/get.dart';

import '../../features/category_details/bindings/category_details_binding.dart';
import '../../features/category_details/views/category_details_view.dart';
import '../../features/known_libraries/bindings/known_libraries_binding.dart';
import '../../features/known_libraries/views/known_libraries_view.dart';
import '../../features/main_shell/bindings/main_binding.dart';
import '../../features/main_shell/views/main_view.dart';
import '../../features/notifications_settings/bindings/notifications_settings_binding.dart';
import '../../features/notifications_settings/views/notifications_settings_view.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/quotes/bindings/quotes_binding.dart';
import '../../features/quotes/views/quotes_view.dart';
import '../../features/read_books/bindings/read_books_binding.dart';
import '../../features/read_books/views/read_books_view.dart';
import '../../features/reader/bindings/reader_binding.dart';
import '../../features/reader/views/reader_view.dart';
import '../../features/reading_timer/bindings/reading_timer_binding.dart';
import '../../features/reading_timer/views/reading_timer_view.dart';
import '../../features/recommendations/bindings/recommendations_binding.dart';
import '../../features/recommendations/views/recommendations_view.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/statistics/bindings/statistics_binding.dart';
import '../../features/statistics/views/statistics_view.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static const String initial = AppRoutes.splash;

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.categoryDetails,
      page: () => const CategoryDetailsView(),
      binding: CategoryDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.reader,
      page: () => const ReaderView(),
      binding: ReaderBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.notificationsSettings,
      page: () => const NotificationsSettingsView(),
      binding: NotificationsSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.readingTimer,
      page: () => const ReadingTimerView(),
      binding: ReadingTimerBinding(),
    ),
    GetPage(
      name: AppRoutes.readBooks,
      page: () => const ReadBooksView(),
      binding: ReadBooksBinding(),
    ),
    GetPage(
      name: AppRoutes.recommendations,
      page: () => const RecommendationsView(),
      binding: RecommendationsBinding(),
    ),
    GetPage(
      name: AppRoutes.knownLibraries,
      page: () => const KnownLibrariesView(),
      binding: KnownLibrariesBinding(),
    ),
    GetPage(
      name: AppRoutes.statistics,
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
    ),
    GetPage(
      name: AppRoutes.quotes,
      page: () => const QuotesView(),
      binding: QuotesBinding(),
    ),
  ];
}
