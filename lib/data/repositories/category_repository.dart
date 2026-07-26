import 'package:sqflite/sqflite.dart';

import '../../core/errors/app_exception.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/database_tables.dart';
import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Database> get _db => _appDatabase.database;

  Future<List<CategoryModel>> getAll() async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
SELECT c.*,
  (SELECT COUNT(*) FROM ${DatabaseTables.books} b WHERE b.category_id = c.id)
    AS book_count
FROM ${DatabaseTables.categories} c
ORDER BY c.created_at ASC
''');
      return rows.map(CategoryModel.fromMap).toList();
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل الأصناف.', cause: e);
    }
  }

  Future<CategoryModel?> getById(int id) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery(
        '''
SELECT c.*,
  (SELECT COUNT(*) FROM ${DatabaseTables.books} b WHERE b.category_id = c.id)
    AS book_count
FROM ${DatabaseTables.categories} c
WHERE c.id = ?
LIMIT 1
''',
        [id],
      );
      if (rows.isEmpty) return null;
      return CategoryModel.fromMap(rows.first);
    } catch (e) {
      throw AppDatabaseException('تعذّر تحميل الصنف.', cause: e);
    }
  }

  Future<CategoryModel> create({
    required String name,
    required String icon,
    required int colorValue,
  }) async {
    try {
      final db = await _db;
      final now = DateTime.now();
      final model = CategoryModel(
        id: 0,
        name: name.trim(),
        icon: icon,
        colorValue: colorValue,
        createdAt: now,
        updatedAt: now,
      );
      final id = await db.insert(DatabaseTables.categories, model.toMap());
      return model.copyWith(id: id);
    } catch (e) {
      throw AppDatabaseException('تعذّر إنشاء الصنف.', cause: e);
    }
  }

  Future<void> update(CategoryModel category) async {
    try {
      final db = await _db;
      final updated = category.copyWith(updatedAt: DateTime.now());
      await db.update(
        DatabaseTables.categories,
        updated.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      throw AppDatabaseException('تعذّر تحديث الصنف.', cause: e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _db;
      final count = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${DatabaseTables.books} WHERE category_id = ?',
              [id],
            ),
          ) ??
          0;
      if (count > 0) {
        throw const AppDatabaseException(
          'لا يمكن حذف الصنف لأنه يحتوي على كتب.',
        );
      }
      await db.delete(
        DatabaseTables.categories,
        where: 'id = ?',
        whereArgs: [id],
      );
    } on AppDatabaseException {
      rethrow;
    } catch (e) {
      throw AppDatabaseException('تعذّر حذف الصنف.', cause: e);
    }
  }
}
