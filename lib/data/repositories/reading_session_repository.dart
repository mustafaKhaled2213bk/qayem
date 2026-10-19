import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/database_tables.dart';
import '../models/reading_session_model.dart';

class ReadingSessionRepository {
  ReadingSessionRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  Future<int> startSession(int bookId) async {
    try {
      final db = await _db;
      return db.insert(DatabaseTables.readingSessions, {
        'book_id': bookId,
        'start_time': DateTime.now().toIso8601String(),
        'end_time': null,
        'duration': 0,
      });
    } catch (e) {
      throw AppDatabaseException('تعذّر بدء جلسة القراءة.', cause: e);
    }
  }

  Future<void> endSession({
    required int sessionId,
    required int durationSeconds,
  }) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseTables.readingSessions,
        {
          'end_time': DateTime.now().toIso8601String(),
          'duration': durationSeconds,
        },
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر إنهاء جلسة القراءة.', cause: e);
    }
  }

  Future<List<ReadingSessionModel>> getByBook(int bookId) async {
    try {
      final db = await _db;
      final rows = await db.query(
        DatabaseTables.readingSessions,
        where: 'book_id = ?',
        whereArgs: [bookId],
        orderBy: 'start_time DESC',
      );
      return rows.map(ReadingSessionModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل جلسات القراءة.', cause: e);
    }
  }

  Future<int> getTodayDurationSeconds() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _sumDuration(start: start, end: end);
  }

  Future<int> getTodayDurationForBook(int bookId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _sumDuration(start: start, end: end, bookId: bookId);
  }

  /// Week starts on Saturday (common in the app locale region).
  Future<int> getWeekDurationForBook(int bookId) async {
    final start = startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    return _sumDuration(start: start, end: end, bookId: bookId);
  }

  Future<int> getDurationForBooksToday(List<int> bookIds) async {
    if (bookIds.isEmpty) return 0;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _sumDuration(start: start, end: end, bookIds: bookIds);
  }

  Future<int> getWeekDurationForBooks(List<int> bookIds) async {
    if (bookIds.isEmpty) return 0;
    final start = startOfWeek(DateTime.now());
    final end = start.add(const Duration(days: 7));
    return _sumDuration(start: start, end: end, bookIds: bookIds);
  }

  static DateTime startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final daysFromSaturday = (day.weekday + 1) % 7;
    return day.subtract(Duration(days: daysFromSaturday));
  }

  Future<int> _sumDuration({
    required DateTime start,
    required DateTime end,
    int? bookId,
    List<int>? bookIds,
  }) async {
    try {
      final db = await _db;
      final where = StringBuffer(
        'start_time >= ? AND start_time < ?',
      );
      final args = <Object?>[
        start.toIso8601String(),
        end.toIso8601String(),
      ];

      if (bookId != null) {
        where.write(' AND book_id = ?');
        args.add(bookId);
      } else if (bookIds != null && bookIds.isNotEmpty) {
        final placeholders = List.filled(bookIds.length, '?').join(', ');
        where.write(' AND book_id IN ($placeholders)');
        args.addAll(bookIds);
      }

      final result = await db.rawQuery(
        '''
SELECT COALESCE(SUM(duration), 0) AS total
FROM ${DatabaseTables.readingSessions}
WHERE $where
''',
        args,
      );
      return (result.first['total'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل تقدم القراءة.', cause: e);
    }
  }
}
