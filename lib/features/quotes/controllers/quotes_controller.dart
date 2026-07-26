import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/quote_repository.dart';

class QuotesController extends GetxController {
  final _quoteRepo = Get.find<QuoteRepository>();
  final _bookRepo = Get.find<BookRepository>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final quotes = <QuoteModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      quotes.assignAll(await _quoteRepo.getAll());
      errorMessage.value = '';
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteQuote(QuoteModel quote) async {
    final confirmed = await AppDialog.confirm(
      title: 'حذف الاقتباس',
      message: 'هل تريد حذف هذا الاقتباس؟',
      confirmLabel: 'حذف',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await _quoteRepo.delete(quote.id);
      quotes.removeWhere((item) => item.id == quote.id);
      AppSnackbar.success('تم', 'تم حذف الاقتباس');
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    }
  }

  Future<void> shareQuote(QuoteModel quote) async {
    final bookName = quote.bookTitle ?? 'كتاب';
    final text =
        '"${quote.content}"\n\n— من كتاب: $bookName\nصفحة ${quote.pageNumber}\nتطبيق قيّم';
    await Clipboard.setData(ClipboardData(text: text));
    AppSnackbar.success(
      'تمت المشاركة',
      'تم نسخ الاقتباس. يمكنك لصقه ومشاركته الآن.',
    );
  }

  Future<void> openInBook(QuoteModel quote) async {
    final book = await _bookRepo.getById(quote.bookId);
    if (book == null) {
      AppSnackbar.error('خطأ', 'الكتاب غير موجود أو تم حذفه.');
      return;
    }

    Get.toNamed(
      AppRoutes.reader,
      arguments: {
        'bookId': quote.bookId,
        'page': quote.pageNumber,
      },
    );
  }
}
