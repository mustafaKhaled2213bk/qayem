import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/app_constants.dart';
import 'database_tables.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createCategories);
    await db.execute(DatabaseTables.createBooks);
    await db.execute(DatabaseTables.createReadingSessions);
    await db.execute(DatabaseTables.createQuotes);
    await db.execute(DatabaseTables.createBooksCategoryIndex);
    await db.execute(DatabaseTables.createBooksLastOpenedIndex);
    await db.execute(DatabaseTables.createQuotesBookIndex);
    await db.execute(DatabaseTables.createQuotesCreatedIndex);
    await _seedDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(DatabaseTables.createQuotes);
      await db.execute(DatabaseTables.createQuotesBookIndex);
      await db.execute(DatabaseTables.createQuotesCreatedIndex);
    }
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();
    final defaults = <Map<String, Object?>>[
      {
        'name': 'أدب',
        'icon': 'menu_book',
        'color': 0xFF042623,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'علوم',
        'icon': 'science',
        'color': 0xFF1B4D3E,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'تطوير ذات',
        'icon': 'psychology',
        'color': 0xFFB9A779,
        'created_at': now,
        'updated_at': now,
      },
      {
        'name': 'تاريخ',
        'icon': 'account_balance',
        'color': 0xFF6B8E6B,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final category in defaults) {
      await db.insert(DatabaseTables.categories, category);
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
