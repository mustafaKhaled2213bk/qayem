import 'package:get/get.dart';

import '../../data/models/book_reminder_model.dart';
import '../../data/repositories/book_reminder_repository.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/reading_session_repository.dart';
import 'notification_service.dart';

class ReadingGoalsSummary {
  const ReadingGoalsSummary({
    required this.dailyGoalMinutes,
    required this.dailyProgressSeconds,
    required this.weeklyGoalMinutes,
    required this.weeklyProgressSeconds,
    required this.enabledCount,
  });

  final int dailyGoalMinutes;
  final int dailyProgressSeconds;
  final int weeklyGoalMinutes;
  final int weeklyProgressSeconds;
  final int enabledCount;

  bool get hasDaily => dailyGoalMinutes > 0;
  bool get hasWeekly => weeklyGoalMinutes > 0;
  bool get hasGoals => enabledCount > 0 && (hasDaily || hasWeekly);
}

class ReadingReminderService {
  ReadingReminderService({
    required BookReminderRepository reminderRepo,
    required ReadingSessionRepository sessionRepo,
    required BookRepository bookRepo,
    required NotificationService notifications,
  })  : _reminderRepo = reminderRepo,
        _sessionRepo = sessionRepo,
        _bookRepo = bookRepo,
        _notifications = notifications;

  final BookReminderRepository _reminderRepo;
  final ReadingSessionRepository _sessionRepo;
  final BookRepository _bookRepo;
  final NotificationService _notifications;

  /// Book ids that currently have a reminder row (enabled or not).
  final reminderBookIds = <int>{}.obs;

  /// Enabled reminders only — used by the book-card alarm icon.
  final enabledReminderBookIds = <int>{}.obs;

  bool hasReminderFor(int bookId) => reminderBookIds.contains(bookId);

  Future<void> refreshBookIds() async {
    final all = await _reminderRepo.getAll();
    reminderBookIds
      ..clear()
      ..addAll(all.map((r) => r.bookId));
    reminderBookIds.refresh();
    enabledReminderBookIds
      ..clear()
      ..addAll(all.where((r) => r.enabled).map((r) => r.bookId));
    enabledReminderBookIds.refresh();
  }

  Future<int> progressSecondsFor(BookReminderModel reminder) =>
      _progressSeconds(reminder);

  Future<BookReminderModel?> getForBook(int bookId) =>
      _reminderRepo.getByBookId(bookId);

  Future<List<BookReminderModel>> getAll() => _reminderRepo.getAll();

  Future<List<BookReminderModel>> getEnabled() => _reminderRepo.getEnabled();

  Future<BookReminderModel> saveReminder({
    required int bookId,
    required bool enabled,
    required int hour,
    required int minute,
    required int goalMinutes,
    required ReminderGoalPeriod goalPeriod,
  }) async {
    if (enabled) {
      await _notifications.ensurePermission();
    }

    final existing = await _reminderRepo.getByBookId(bookId);
    final now = DateTime.now();
    final saved = await _reminderRepo.upsert(
      BookReminderModel(
        id: existing?.id ?? 0,
        bookId: bookId,
        enabled: enabled,
        hour: hour,
        minute: minute,
        goalMinutes: goalMinutes,
        goalPeriod: goalPeriod,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        bookTitle: existing?.bookTitle,
      ),
    );

    await syncReminder(saved);
    await refreshBookIds();
    return saved;
  }

  Future<void> setEnabled(int bookId, bool enabled) async {
    if (enabled) {
      await _notifications.ensurePermission();
    }
    await _reminderRepo.setEnabled(bookId, enabled);
    final reminder = await _reminderRepo.getByBookId(bookId);
    if (reminder == null) return;
    await syncReminder(reminder);
    await refreshBookIds();
  }

  Future<void> deleteReminder(int bookId) async {
    await _notifications.cancelBookReminder(bookId);
    await _reminderRepo.deleteByBookId(bookId);
    await refreshBookIds();
  }

  Future<void> syncAll() async {
    final reminders = await _reminderRepo.getAll();
    for (final reminder in reminders) {
      await syncReminder(reminder);
    }
    await refreshBookIds();
  }

  Future<void> syncReminder(BookReminderModel reminder) async {
    if (!reminder.enabled) {
      await _notifications.cancelBookReminder(reminder.bookId);
      return;
    }

    final book = await _bookRepo.getById(reminder.bookId);
    final title = book?.title ?? reminder.bookTitle ?? 'كتابك';
    final progressSeconds = await _progressSeconds(reminder);
    final met = progressSeconds >= reminder.goalMinutes * 60;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = !met
        ? today
        : reminder.goalPeriod == ReminderGoalPeriod.weekly
            ? ReadingSessionRepository.startOfWeek(now).add(const Duration(days: 7))
            : today.add(const Duration(days: 1));

    await _notifications.scheduleDailyWindow(
      bookId: reminder.bookId,
      bookTitle: title,
      body: _bodyFor(reminder),
      hour: reminder.hour,
      minute: reminder.minute,
      startDay: startDay,
    );
  }

  Future<void> syncAfterReading(int bookId) async {
    final reminder = await _reminderRepo.getByBookId(bookId);
    if (reminder == null || !reminder.enabled) return;
    await syncReminder(reminder);
  }

  Future<ReadingGoalsSummary> goalsSummary() async {
    final enabled = await _reminderRepo.getEnabled();
    if (enabled.isEmpty) {
      return const ReadingGoalsSummary(
        dailyGoalMinutes: 0,
        dailyProgressSeconds: 0,
        weeklyGoalMinutes: 0,
        weeklyProgressSeconds: 0,
        enabledCount: 0,
      );
    }

    final dailyIds = <int>[];
    final weeklyIds = <int>[];
    var dailyGoal = 0;
    var weeklyGoal = 0;
    for (final reminder in enabled) {
      if (reminder.goalPeriod == ReminderGoalPeriod.daily) {
        dailyIds.add(reminder.bookId);
        dailyGoal += reminder.goalMinutes;
      } else {
        weeklyIds.add(reminder.bookId);
        weeklyGoal += reminder.goalMinutes;
      }
    }

    final dailySeconds = await _sessionRepo.getDurationForBooksToday(dailyIds);
    final weeklySeconds = await _sessionRepo.getWeekDurationForBooks(weeklyIds);

    return ReadingGoalsSummary(
      dailyGoalMinutes: dailyGoal,
      dailyProgressSeconds: dailySeconds,
      weeklyGoalMinutes: weeklyGoal,
      weeklyProgressSeconds: weeklySeconds,
      enabledCount: enabled.length,
    );
  }

  Future<int> _progressSeconds(BookReminderModel reminder) async {
    return switch (reminder.goalPeriod) {
      ReminderGoalPeriod.daily =>
        _sessionRepo.getTodayDurationForBook(reminder.bookId),
      ReminderGoalPeriod.weekly =>
        _sessionRepo.getWeekDurationForBook(reminder.bookId),
    };
  }

  String _bodyFor(BookReminderModel reminder) {
    final period = reminder.goalPeriod == ReminderGoalPeriod.weekly
        ? 'هذا الأسبوع'
        : 'اليوم';
    return 'هدفك ${reminder.goalMinutes} دقيقة $period.';
  }

}
