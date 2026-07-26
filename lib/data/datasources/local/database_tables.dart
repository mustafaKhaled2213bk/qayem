abstract final class DatabaseTables {
  static const String categories = 'categories';
  static const String books = 'books';
  static const String readingSessions = 'reading_sessions';
  static const String quotes = 'quotes';

  static const String createCategories = '''
CREATE TABLE $categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  color INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''';

  static const String createBooks = '''
CREATE TABLE $books (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  file_path TEXT NOT NULL,
  category_id INTEGER NOT NULL,
  cover_path TEXT,
  current_page INTEGER NOT NULL DEFAULT 1,
  total_pages INTEGER NOT NULL DEFAULT 0,
  progress REAL NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  last_opened_at TEXT,
  is_completed INTEGER NOT NULL DEFAULT 0,
  total_reading_time INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (category_id) REFERENCES $categories (id)
    ON DELETE RESTRICT
)
''';

  static const String createReadingSessions = '''
CREATE TABLE $readingSessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT,
  duration INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (book_id) REFERENCES $books (id)
    ON DELETE CASCADE
)
''';

  static const String createBooksCategoryIndex = '''
CREATE INDEX idx_books_category_id ON $books (category_id)
''';

  static const String createBooksLastOpenedIndex = '''
CREATE INDEX idx_books_last_opened_at ON $books (last_opened_at)
''';

  static const String createQuotes = '''
CREATE TABLE $quotes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER NOT NULL,
  page_number INTEGER NOT NULL,
  content TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (book_id) REFERENCES $books (id)
    ON DELETE CASCADE
)
''';

  static const String createQuotesBookIndex = '''
CREATE INDEX idx_quotes_book_id ON $quotes (book_id)
''';

  static const String createQuotesCreatedIndex = '''
CREATE INDEX idx_quotes_created_at ON $quotes (created_at)
''';
}
