import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/reading_reminder_service.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/book_reminder_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../book_reminder/widgets/book_reminder_sheet.dart';
import '../../home/controllers/home_controller.dart';

class NotificationsSettingsController extends GetxController {
  final _reminderService = Get.find<ReadingReminderService>();
  final _bookRepo = Get.find<BookRepository>();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final reminders = <BookReminderModel>[].obs;
  final booksWithoutReminder = <BookModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final allReminders = await _reminderService.getAll();
      final allBooks = await _bookRepo.getAll();
      final remindedIds = allReminders.map((r) => r.bookId).toSet();
      reminders.assignAll(allReminders);
      booksWithoutReminder.assignAll(
        allBooks.where((b) => !remindedIds.contains(b.id)).toList(),
      );
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggle(BookReminderModel reminder, bool enabled) async {
    try {
      isSaving.value = true;
      await _reminderService.setEnabled(reminder.bookId, enabled);
      await load();
      _refreshHome();
      AppSnackbar.success(
        'تم',
        enabled ? 'تم تفعيل التذكير' : 'تم إيقاف التذكير',
      );
    } on AppException catch (e) {
      AppSnackbar.error('خطأ', e.message);
      await load();
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> editReminder(BookReminderModel reminder) async {
    final book = await _bookRepo.getById(reminder.bookId);
    if (book == null) {
      AppSnackbar.error('خطأ', 'الكتاب غير موجود.');
      return;
    }
    // BookReminderSheet.show refreshes dependent UI when changed.
    await BookReminderSheet.show(book);
  }

  Future<void> addReminderForBook(BookModel book) async {
    await BookReminderSheet.show(book);
  }

  Future<void> pickBookToAdd() async {
    if (booksWithoutReminder.isEmpty) {
      AppSnackbar.info('تنبيه', 'كل كتبك لديها تذكير بالفعل، أو لا توجد كتب.');
      return;
    }

    final selected = await Get.bottomSheet<BookModel>(
      SafeArea(
        child: SizedBox(
          height: Get.height * 0.55,
          child: Column(
            children: [
              const ListTile(title: Text('اختر كتاباً')),
              Expanded(
                child: ListView.builder(
                  itemCount: booksWithoutReminder.length,
                  itemBuilder: (context, index) {
                    final book = booksWithoutReminder[index];
                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text(book.categoryName ?? ''),
                      onTap: () => Get.back(result: book),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
      isScrollControlled: true,
    );
    if (selected == null) return;
    await addReminderForBook(selected);
  }

  void openBook(BookReminderModel reminder) {
    Get.toNamed(AppRoutes.reader, arguments: reminder.bookId);
  }

  void _refreshHome() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().load();
    }
  }
}
