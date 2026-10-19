import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/database_tables.dart';
import '../models/book_reminder_model.dart';

class BookReminderRepository {
  BookReminderRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  static const String _joinSelect = '''
SELECT r.*, b.title AS book_title
FROM ${DatabaseTables.bookReminders} r
INNER JOIN ${DatabaseTables.books} b ON b.id = r.book_id
''';

  Future<BookReminderModel?> getByBookId(int bookId) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery(
        '''
$_joinSelect
WHERE r.book_id = ?
LIMIT 1
''',
        [bookId],
      );
      if (rows.isEmpty) return null;
      return BookReminderModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل تذكير الكتاب.', cause: e);
    }
  }

  Future<List<BookReminderModel>> getAll() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
$_joinSelect
ORDER BY b.title COLLATE NOCASE ASC
''');
      return rows.map(BookReminderModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل التذكيرات.', cause: e);
    }
  }

  Future<List<BookReminderModel>> getEnabled() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
$_joinSelect
WHERE r.enabled = 1
ORDER BY r.hour ASC, r.minute ASC
''');
      return rows.map(BookReminderModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل التذكيرات المفعّلة.', cause: e);
    }
  }

  Future<BookReminderModel> upsert(BookReminderModel reminder) async {
    try {
      final db = await _db;
      final now = DateTime.now();
      final existing = await getByBookId(reminder.bookId);

      if (existing == null) {
        final toInsert = reminder.copyWith(
          id: 0,
          createdAt: now,
          updatedAt: now,
        );
        final id = await db.insert(
          DatabaseTables.bookReminders,
          toInsert.toMap(),
        );
        return (await getByBookId(reminder.bookId)) ??
            toInsert.copyWith(id: id);
      }

      final updated = reminder.copyWith(
        id: existing.id,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
      await db.update(
        DatabaseTables.bookReminders,
        updated.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return (await getByBookId(reminder.bookId)) ?? updated;
    } catch (e) {
      throw AppDatabaseException('تعذّر حفظ تذكير الكتاب.', cause: e);
    }
  }

  Future<void> setEnabled(int bookId, bool enabled) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseTables.bookReminders,
        {
          'enabled': enabled ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر تحديث حالة التذكير.', cause: e);
    }
  }

  Future<void> deleteByBookId(int bookId) async {
    try {
      final db = await _db;
      await db.delete(
        DatabaseTables.bookReminders,
        where: 'book_id = ?',
        whereArgs: [bookId],
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر حذف تذكير الكتاب.', cause: e);
    }
  }
}
