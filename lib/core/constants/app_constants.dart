abstract final class AppConstants {
  static const String appName = 'قيّم';
  static const String appTagline = 'رفيقك في رحلة القراءة';
  static const String databaseName = 'qayem.db';
  static const int databaseVersion = 2;

  static const int splashDurationMs = 2200;
  static const int progressSaveDebounceMs = 800;
  static const int recentBooksLimit = 3;
  static const int featuredCategoriesLimit = 4;

  static const int dailyReminderNotificationId = 1001;
  static const String dailyReminderChannelId = 'daily_reading_reminder';
  static const String dailyReminderChannelName = 'تذكير القراءة اليومي';
  static const String dailyReminderChannelDescription =
      'تذكيرات يومية لتشجيعك على القراءة';

  static const String notificationTitle = 'حان وقت القراءة';
  static const String notificationBody = 'خذ بعض الوقت لقراءة كتابك اليوم.';

  static const double designWidth = 375;
  static const double designHeight = 812;
}
