abstract final class AppConstants {
  static const String appName = 'قيّم';
  static const String appTagline = 'رفيقك في رحلة القراءة';
  static const String databaseName = 'qayem.db';
  static const int databaseVersion = 3;

  static const int splashDurationMs = 2200;
  static const int progressSaveDebounceMs = 800;
  static const int recentBooksLimit = 3;
  static const int featuredCategoriesLimit = 4;

  /// Legacy single-reminder id — cancelled on upgrade/init.
  static const int legacyDailyReminderNotificationId = 1001;

  /// Per-book notification ids use [bookReminderNotificationIdBase] + bookId.
  static const int bookReminderNotificationIdBase = 200000;

  static const String dailyReminderChannelId = 'daily_reading_reminder';
  static const String dailyReminderChannelName = 'تذكير القراءة';
  static const String dailyReminderChannelDescription =
      'تذكيرات يومية لتشجيعك على قراءة كتبك';

  static const String notificationTitle = 'حان وقت القراءة';

  static const List<int> dailyGoalMinuteOptions = [10, 15, 20, 30, 45, 60];
  static const List<int> weeklyGoalMinuteOptions = [
    60,
    90,
    120,
    180,
    240,
    360,
  ];

  static const double designWidth = 375;
  static const double designHeight = 812;
}
