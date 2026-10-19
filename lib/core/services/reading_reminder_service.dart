import 'package:get/get.dart';

import '../../data/models/book_reminder_model.dart';
import '../../data/repositories/book_reminder_repository.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/reading_session_repository.dart';
import 'notification_service.dart';

class ReadingGoalsSummary {
  const ReadingGoalsSummary({
    required this.goalMinutes,
    required this.todaySeconds,
    required this.enabledCount,
  });

  final int goalMinutes;
  final int todaySeconds;
  final int enabledCount;

  bool get hasGoals => enabledCount > 0 && goalMinutes > 0;

  double get progress {
    if (goalMinutes <= 0) return 0;
    return (todaySeconds / (goalMinutes * 60)).clamp(0.0, 1.0);
  }
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

  bool hasReminderFor(int bookId) => reminderBookIds.contains(bookId);

  Future<void> refreshBookIds() async {
    final all = await _reminderRepo.getAll();
    final ids = all.map((r) => r.bookId).toSet();
    reminderBookIds
      ..clear()
      ..addAll(ids);
    reminderBookIds.refresh();
  }

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
    final goalSeconds = reminder.goalMinutes * 60;
    final remaining = (goalSeconds - progressSeconds).clamp(0, goalSeconds);
    final met = progressSeconds >= goalSeconds;

    if (met) {
      // Skip remaining fires in this period; resume at the next period.
      final after = reminder.goalPeriod == ReminderGoalPeriod.weekly
          ? ReadingSessionRepository.startOfWeek(DateTime.now())
              .add(const Duration(days: 7))
          : DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ).add(const Duration(days: 1));
      await _notifications.scheduleBookReminderAfter(
        reminder: reminder,
        bookTitle: title,
        body: _bodyFor(
          reminder,
          remainingSeconds: goalSeconds,
          met: false,
        ),
        after: after,
      );
      return;
    }

    await _notifications.scheduleBookReminder(
      reminder: reminder,
      bookTitle: title,
      body: _bodyFor(
        reminder,
        remainingSeconds: remaining,
        met: false,
      ),
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
        goalMinutes: 0,
        todaySeconds: 0,
        enabledCount: 0,
      );
    }

    final goalMinutes =
        enabled.fold<int>(0, (sum, r) => sum + r.dailyShareMinutes);
    final bookIds = enabled.map((r) => r.bookId).toList();
    final todaySeconds =
        await _sessionRepo.getDurationForBooksToday(bookIds);

    return ReadingGoalsSummary(
      goalMinutes: goalMinutes,
      todaySeconds: todaySeconds,
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

  String _bodyFor(
    BookReminderModel reminder, {
    required int remainingSeconds,
    required bool met,
  }) {
    if (met) {
      return reminder.goalPeriod == ReminderGoalPeriod.weekly
          ? 'أحسنت! حققت هدفك الأسبوعي. نراك الفترة القادمة.'
          : 'أحسنت! حققت هدفك اليوم. نراك غداً.';
    }

    final remainingMinutes = (remainingSeconds / 60).ceil().clamp(1, 24 * 60);
    final periodLabel =
        reminder.goalPeriod == ReminderGoalPeriod.weekly ? 'هذا الأسبوع' : 'اليوم';
    return 'متبقّى $remainingMinutes دقيقة $periodLabel — هدفك ${reminder.goalMinutes} دقيقة.';
  }

}
