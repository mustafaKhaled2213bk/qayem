import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/database_tables.dart';
import '../models/book_model.dart';

class BookRepository {
  BookRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  static const String _joinSelect = '''
SELECT b.*,
  c.name AS category_name,
  c.color AS category_color
FROM ${DatabaseTables.books} b
LEFT JOIN ${DatabaseTables.categories} c ON c.id = b.category_id
''';

  Future<List<BookModel>> getAll() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
$_joinSelect
ORDER BY COALESCE(b.last_opened_at, b.created_at) DESC
''');
      return rows.map(BookModel.fromMap).toList();
    } catch (e) {
      log(e.toString());
      throw AppDatabaseException('تعذّر تحميل الكتب.', cause: e);
    }
  }

  Future<List<BookModel>> getRecent({int limit = 3}) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
$_joinSelect
WHERE b.last_opened_at IS NOT NULL
ORDER BY b.last_opened_at DESC
LIMIT ?
''', [limit]);
      return rows.map(BookModel.fromMap).toList();
    } catch (e) {
      log(e.toString());
      throw AppDatabaseException('تعذّر تحميل آخر الكتب.', cause: e);
    }
  }

  Future<List<BookModel>> getByCategory(int categoryId) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
$_joinSelect
WHERE b.category_id = ?
ORDER BY COALESCE(b.last_opened_at, b.created_at) DESC
''', [categoryId]);
      return rows.map(BookModel.fromMap).toList();
    } catch (e) {
      log(e.toString());
      throw AppDatabaseException('تعذّر تحميل كتب الصنف.', cause: e);
    }
  }

  Future<List<BookModel>> getCompleted() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
$_joinSelect
WHERE b.is_completed = 1
ORDER BY b.last_opened_at DESC
''');
      return rows.map(BookModel.fromMap).toList();
    } catch (e) {
      log(e.toString());
      throw AppDatabaseException('تعذّر تحميل الكتب المقروءة.', cause: e);
    }
  }

  Future<List<BookModel>> search(String query) async {
    try {
      final db = await _db;
      final like = '%${query.trim()}%';
      final rows = await db.rawQuery('''
$_joinSelect
WHERE b.title LIKE ?
ORDER BY b.title ASC
''', [like]);
      return rows.map(BookModel.fromMap).toList();
    } catch (e) {
      log(e.toString());
      throw AppDatabaseException('تعذّر البحث في الكتب.', cause: e);
    }
  }

  Future<BookModel?> getById(int id) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
$_joinSelect
WHERE b.id = ?
LIMIT 1
''', [id]);
      if (rows.isEmpty) return null;
      return BookModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل الكتاب.', cause: e);
    }
  }

  Future<BookModel> create({
    required String title,
    required String filePath,
    required int categoryId,
    int totalPages = 0,
  }) async {
    try {
      final db = await _db;
      final now = DateTime.now();
      final model = BookModel(
        id: 0,
        title: title.trim(),
        filePath: filePath,
        categoryId: categoryId,
        currentPage: 1,
        totalPages: totalPages,
        progress: 0,
        createdAt: now,
        lastOpenedAt: null,
        isCompleted: false,
        totalReadingTime: 0,
      );
      final id = await db.insert(DatabaseTables.books, model.toMap());
      return (await getById(id))!;
    } catch (e) {
      throw AppDatabaseException('تعذّر حفظ الكتاب.', cause: e);
    }
  }

  Future<void> updateProgress({
    required int bookId,
    required int currentPage,
    required int totalPages,
  }) async {
    try {
      final db = await _db;
      final progress =
          totalPages <= 0 ? 0.0 : (currentPage / totalPages).clamp(0.0, 1.0);
      final isCompleted = totalPages > 0 && currentPage >= totalPages;
      await db.update(
        DatabaseTables.books,
        {
          'current_page': currentPage,
          'total_pages': totalPages,
          'progress': progress,
          'is_completed': isCompleted ? 1 : 0,
          'last_opened_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [bookId],
      );
    } catch (e) {
      log(e.toString());
      throw AppDatabaseException('تعذّر حفظ تقدم القراءة.', cause: e);
    }
  }

  Future<void> markOpened(int bookId) async {
    try {
      final db = await _db;
      await db.update(
        DatabaseTables.books,
        {'last_opened_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [bookId],
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر تحديث آخر فتح.', cause: e);
    }
  }

  Future<void> addReadingTime(int bookId, int seconds) async {
    if (seconds <= 0) return;
    try {
      final db = await _db;
      await db.rawUpdate(
        '''
UPDATE ${DatabaseTables.books}
SET total_reading_time = total_reading_time + ?
WHERE id = ?
''',
        [seconds, bookId],
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر حفظ وقت القراءة.', cause: e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _db;
      await db.delete(
        DatabaseTables.books,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر حذف الكتاب.', cause: e);
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await _db;
      await db.delete(DatabaseTables.readingSessions);
      await db.delete(DatabaseTables.books);
    } catch (e) {
      throw AppDatabaseException('تعذّر مسح الكتب.', cause: e);
    }
  }

  Future<void> clearHistory() async {
    try {
      final db = await _db;
      await db.update(
        DatabaseTables.books,
        {
          'current_page': 1,
          'progress': 0,
          'is_completed': 0,
          'last_opened_at': null,
          'total_reading_time': 0,
        },
      );
      await db.delete(DatabaseTables.readingSessions);
    } catch (e) {
      log(e.toString());
      throw AppDatabaseException('تعذّر مسح سجل القراءة.', cause: e);
    }
  }

  Future<ReadingStats> getStats() async {
    try {
      final db = await _db;
      final total = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseTables.books}'),
          ) ??
          0;
      final completed = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseTables.books} WHERE is_completed = 1',
            ),
          ) ??
          0;
      final reading = Sqflite.firstIntValue(
            await db.rawQuery('''
SELECT COUNT(*) FROM ${DatabaseTables.books}
WHERE is_completed = 0 AND last_opened_at IS NOT NULL
'''),
          ) ??
          0;
      final readingTime = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COALESCE(SUM(total_reading_time), 0) FROM ${DatabaseTables.books}',
            ),
          ) ??
          0;
      final pagesRead = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COALESCE(SUM(current_page), 0) FROM ${DatabaseTables.books}',
            ),
          ) ??
          0;

      return ReadingStats(
        totalBooks: total,
        completedBooks: completed,
        currentlyReading: reading,
        totalReadingTime: readingTime,
        pagesRead: pagesRead,
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل الإحصائيات.', cause: e);
    }
  }
}

class ReadingStats {
  const ReadingStats({
    required this.totalBooks,
    required this.completedBooks,
    required this.currentlyReading,
    required this.totalReadingTime,
    required this.pagesRead,
  });

  final int totalBooks;
  final int completedBooks;
  final int currentlyReading;
  final int totalReadingTime;
  final int pagesRead;
}
