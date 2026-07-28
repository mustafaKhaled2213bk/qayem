import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/share_service.dart';
import '../../../core/utils/quote_image_capture.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/quote_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/quote_repository.dart';
import '../widgets/edit_quote_dialog.dart';
import '../widgets/quote_image_preview.dart';

class QuotesController extends GetxController {
  final _quoteRepo = Get.find<QuoteRepository>();
  final _bookRepo = Get.find<BookRepository>();
  final _shareService = Get.find<ShareService>();

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

  Future<void> editQuote(QuoteModel quote) async {
    final result = await Get.dialog<QuoteEditResult>(
      EditQuoteDialog(quote: quote),
    );
    if (result == null) return;

    try {
      final updated = await _quoteRepo.update(
        id: quote.id,
        content: result.content,
        pageNumber: result.pageNumber,
      );
      final index = quotes.indexWhere((item) => item.id == quote.id);
      if (index != -1) {
        quotes[index] = updated;
        quotes.refresh();
      }
      AppSnackbar.success('تم', 'تم تحديث الاقتباس');
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    } catch (_) {
      AppSnackbar.error('خطأ', 'تعذّر تحديث الاقتباس.');
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

  void openQuoteImage(QuoteModel quote) {
    QuoteImagePreview.show(quote);
  }

  Future<void> shareQuoteImage({
    required QuoteModel quote,
    required GlobalKey boundaryKey,
  }) async {
    try {
      // Allow one frame so RepaintBoundary paints fully before capture.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final bytes = await QuoteImageCapture.capturePng(boundaryKey);
      await _shareService.shareQuoteImage(quote: quote, imageBytes: bytes);
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
    } catch (_) {
      AppSnackbar.error('خطأ', 'تعذّرت مشاركة صورة الاقتباس.');
    }
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
