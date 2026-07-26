import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/database_tables.dart';
import '../models/quote_model.dart';

class QuoteRepository {
  QuoteRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  Future<List<QuoteModel>> getAll() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
SELECT q.*, b.title AS book_title
FROM ${DatabaseTables.quotes} q
LEFT JOIN ${DatabaseTables.books} b ON b.id = q.book_id
ORDER BY q.created_at DESC
''');
      return rows.map(QuoteModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل الاقتباسات.', cause: e);
    }
  }

  Future<QuoteModel> create({
    required int bookId,
    required int pageNumber,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw const AppDatabaseException('لا يمكن حفظ اقتباس فارغ.');
    }

    try {
      final db = await _db;
      final model = QuoteModel(
        id: 0,
        bookId: bookId,
        pageNumber: pageNumber,
        content: trimmed,
        createdAt: DateTime.now(),
      );
      final id = await db.insert(DatabaseTables.quotes, model.toMap());
      final rows = await db.rawQuery('''
SELECT q.*, b.title AS book_title
FROM ${DatabaseTables.quotes} q
LEFT JOIN ${DatabaseTables.books} b ON b.id = q.book_id
WHERE q.id = ?
LIMIT 1
''', [id]);
      return QuoteModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException('تعذّر حفظ الاقتباس.', cause: e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _db;
      await db.delete(
        DatabaseTables.quotes,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر حذف الاقتباس.', cause: e);
    }
  }
}
