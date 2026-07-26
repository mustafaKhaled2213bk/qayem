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
}
