import 'dart:io';

import 'package:share_plus/share_plus.dart';

import '../errors/app_exception.dart';
import '../../data/models/book_model.dart';
import '../../data/models/quote_model.dart';

class ShareService {
  Future<void> shareQuote(QuoteModel quote) async {
    final bookName = quote.bookTitle ?? 'كتاب';
    final text =
        '"${quote.content}"\n\n— من كتاب: $bookName\nصفحة ${quote.pageNumber}\nتطبيق قيّم';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'اقتباس من $bookName',
        title: 'مشاركة اقتباس',
      ),
    );
  }

  Future<void> shareBook(BookModel book) async {
    final file = File(book.filePath);
    if (!await file.exists()) {
      throw const FileException('ملف الكتاب غير موجود أو تم حذفه.');
    }

    final category = book.categoryName;
    final text = category == null || category.isEmpty
        ? 'كتاب: ${book.title}\nمن تطبيق قيّم'
        : 'كتاب: ${book.title}\nالصنف: $category\nمن تطبيق قيّم';

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            book.filePath,
            mimeType: 'application/pdf',
            name: '${book.title}.pdf',
          ),
        ],
        text: text,
        subject: book.title,
        title: 'مشاركة كتاب',
      ),
    );
  }
}
