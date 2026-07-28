import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'core/services/file_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/pdf_cover_service.dart';
import 'core/services/share_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/theme_service.dart';
import 'data/datasources/local/app_database.dart';
import 'data/repositories/book_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/quote_repository.dart';
import 'data/repositories/reading_session_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storage = await StorageService.init();
  Get.put<StorageService>(storage, permanent: true);

  final themeService = ThemeService(storage);
  Get.put<ThemeService>(themeService, permanent: true);

  final database = AppDatabase.instance;
  await database.database;
  Get.put<AppDatabase>(database, permanent: true);

  final fileService = FileService();
  Get.put<FileService>(fileService, permanent: true);
  Get.put<ShareService>(ShareService(), permanent: true);
  Get.put<CategoryRepository>(CategoryRepository(database), permanent: true);
  final bookRepo = BookRepository(database);
  Get.put<BookRepository>(bookRepo, permanent: true);
  Get.put<ReadingSessionRepository>(
    ReadingSessionRepository(database),
    permanent: true,
  );
  Get.put<QuoteRepository>(QuoteRepository(database), permanent: true);
  Get.put<PdfCoverService>(
    PdfCoverService(bookRepo, fileService),
    permanent: true,
  );

  final notifications = NotificationService(storage);
  Get.put<NotificationService>(notifications, permanent: true);
  await notifications.init();

  runApp(const QayemApp());
}
