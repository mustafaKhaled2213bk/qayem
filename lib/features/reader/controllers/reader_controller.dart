import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/debounce.dart';
import '../../../data/models/book_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../../data/repositories/reading_session_repository.dart';
import '../widgets/reading_timer_sheet.dart';

enum ReaderState { loading, ready, missingFile, error }

enum TimerState { idle, running, paused, stopped }

class ReaderController extends GetxController {
  final _bookRepo = Get.find<BookRepository>();
  final _sessionRepo = Get.find<ReadingSessionRepository>();
  final _quoteRepo = Get.find<QuoteRepository>();

  final readerState = ReaderState.loading.obs;
  final errorMessage = ''.obs;
  final book = Rxn<BookModel>();
  final showControls = false.obs;
  final currentPage = 1.obs;
  final totalPages = 0.obs;

  final timerState = TimerState.idle.obs;
  final elapsedSeconds = 0.obs;

  final hasTextSelection = false.obs;
  final isSavingQuote = false.obs;

  PdfViewerController? pdfController;
  PdfTextSelection? _textSelection;
  final Debouncer _progressDebouncer = Debouncer(
    delay: const Duration(milliseconds: AppConstants.progressSaveDebounceMs),
  );

  Timer? _tickTimer;
  int? _sessionId;
  DateTime? _timerStartedAt;
  int _accumulatedSeconds = 0;
  int? _initialPageOverride;

  late final int bookId;

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    pdfController = PdfViewerController();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args is Map) {
      bookId = args['bookId'] as int;
      _initialPageOverride = args['page'] as int?;
    } else {
      bookId = args as int;
    }
  }

  @override
  void onReady() {
    super.onReady();
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      readerState.value = ReaderState.loading;
      final loaded = await _bookRepo.getById(bookId);
      if (loaded == null) {
        errorMessage.value = 'الكتاب غير موجود.';
        readerState.value = ReaderState.error;
        return;
      }

      book.value = loaded;
      final preferredPage = _initialPageOverride ?? loaded.currentPage;
      currentPage.value = preferredPage.clamp(1, 999999);
      totalPages.value = loaded.totalPages;

      final exists = await File(loaded.filePath).exists();
      if (!exists) {
        errorMessage.value = 'ملف PDF غير موجود أو تم حذفه من الجهاز.';
        readerState.value = ReaderState.missingFile;
        return;
      }

      await _bookRepo.markOpened(bookId);
      readerState.value = ReaderState.ready;
    } on AppException catch (e) {
      errorMessage.value = e.message;
      readerState.value = ReaderState.error;
    } catch (_) {
      errorMessage.value = 'تعذّر فتح الملف.';
      readerState.value = ReaderState.error;
    }
  }

  void toggleControls() => showControls.value = !showControls.value;

  void onDocumentReady(PdfDocument document) {
    totalPages.value = document.pages.length;
    final target = currentPage.value.clamp(1, totalPages.value);
    currentPage.value = target;
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      pdfController?.goToPage(pageNumber: target);
    });
    _persistProgress(target, totalPages.value);
  }

  void onPageChanged(int? pageNumber) {
    if (pageNumber == null) return;
    currentPage.value = pageNumber;
    _progressDebouncer.call(() {
      _persistProgress(pageNumber, totalPages.value);
    });
  }

  void onTextSelectionChange(PdfTextSelection selection) {
    _textSelection = selection;
    hasTextSelection.value = selection.hasSelectedText;
  }

  Future<void> saveSelectedQuote({
    PdfTextSelectionDelegate? selectionDelegate,
  }) async {
    if (isSavingQuote.value) return;

    try {
      isSavingQuote.value = true;
      final selection = selectionDelegate ??
          pdfController?.textSelectionDelegate ??
          _textSelection;
      if (selection == null || !selection.hasSelectedText) {
        Get.snackbar('تنبيه', 'حدّد نصاً أولاً لحفظ الاقتباس.');
        return;
      }

      final text = (await selection.getSelectedText()).trim();
      if (text.isEmpty) {
        Get.snackbar('تنبيه', 'النص المحدد فارغ.');
        return;
      }

      await _quoteRepo.create(
        bookId: bookId,
        pageNumber: currentPage.value,
        content: text,
      );

      await selectionDelegate?.clearTextSelection();
      await pdfController?.textSelectionDelegate.clearTextSelection();
      hasTextSelection.value = false;

      Get.snackbar('تم', 'تم حفظ الاقتباس بنجاح');
    } on AppException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (_) {
      Get.snackbar('خطأ', 'تعذّر حفظ الاقتباس.');
    } finally {
      isSavingQuote.value = false;
    }
  }

  Future<void> _persistProgress(int page, int total) async {
    if (total <= 0) return;
    try {
      await _bookRepo.updateProgress(
        bookId: bookId,
        currentPage: page,
        totalPages: total,
      );
      final refreshed = await _bookRepo.getById(bookId);
      if (refreshed != null) book.value = refreshed;
    } catch (_) {
      // Keep reading UX smooth; persistence will retry on next change.
    }
  }

  bool onGeneralTap(
    BuildContext context,
    PdfViewerController controller,
    PdfViewerGeneralTapHandlerDetails details,
  ) {
    if (hasTextSelection.value) return false;

    if (details.type == PdfViewerGeneralTapType.tap) {
      toggleControls();
      return true;
    }
    if (details.type == PdfViewerGeneralTapType.longPress) {
      showTimer();
      return true;
    }
    return false;
  }

  void showTimer() {
    showControls.value = false;
    Get.bottomSheet(
      const ReadingTimerSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }

  Future<void> startTimer() async {
    if (timerState.value == TimerState.running) return;

    if (timerState.value == TimerState.idle ||
        timerState.value == TimerState.stopped) {
      _accumulatedSeconds = 0;
      elapsedSeconds.value = 0;
      _sessionId = await _sessionRepo.startSession(bookId);
    }

    _timerStartedAt = DateTime.now();
    timerState.value = TimerState.running;
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final running = DateTime.now().difference(_timerStartedAt!).inSeconds;
      elapsedSeconds.value = _accumulatedSeconds + running;
    });
  }

  void pauseTimer() {
    if (timerState.value != TimerState.running) return;
    _accumulatedSeconds = elapsedSeconds.value;
    _timerStartedAt = null;
    _tickTimer?.cancel();
    timerState.value = TimerState.paused;
  }

  Future<void> stopTimer() async {
    if (timerState.value == TimerState.idle) return;

    if (timerState.value == TimerState.running && _timerStartedAt != null) {
      _accumulatedSeconds = elapsedSeconds.value;
    }

    _tickTimer?.cancel();
    timerState.value = TimerState.stopped;

    final seconds = _accumulatedSeconds;
    if (_sessionId != null) {
      await _sessionRepo.endSession(
        sessionId: _sessionId!,
        durationSeconds: seconds,
      );
      _sessionId = null;
    }
    await _bookRepo.addReadingTime(bookId, seconds);
    final refreshed = await _bookRepo.getById(bookId);
    if (refreshed != null) book.value = refreshed;
  }

  void resetTimer() {
    _tickTimer?.cancel();
    _timerStartedAt = null;
    _accumulatedSeconds = 0;
    elapsedSeconds.value = 0;
    timerState.value = TimerState.idle;
  }

  Future<void> _flushTimerOnClose() async {
    if (timerState.value == TimerState.running ||
        timerState.value == TimerState.paused) {
      await stopTimer();
    }
  }

  @override
  void onClose() {
    _progressDebouncer.dispose();
    _tickTimer?.cancel();
    unawaited(_flushTimerOnClose());
    unawaited(_persistProgress(currentPage.value, totalPages.value));
    super.onClose();
  }
}
