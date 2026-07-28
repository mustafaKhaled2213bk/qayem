import 'dart:io';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../data/models/book_model.dart';
import '../../data/repositories/book_repository.dart';
import 'file_service.dart';

class PdfCoverService {
  PdfCoverService(this._bookRepo, this._fileService);

  final BookRepository _bookRepo;
  final FileService _fileService;

  final Map<int, Future<String?>> _inFlight = {};

  Future<String?> generateCover(String pdfPath, {String? preferredName}) async {
    PdfDocument? document;
    PdfImage? pdfImage;
    ui.Image? uiImage;

    try {
      if (!await _fileService.fileExists(pdfPath)) return null;

      document = await PdfDocument.openFile(pdfPath);
      if (document.pages.isEmpty) return null;

      final page = document.pages.first;
      const targetWidth = 360.0;
      final scale = targetWidth / page.width;

      pdfImage = await page.render(
        fullWidth: page.width * scale,
        fullHeight: page.height * scale,
      );
      if (pdfImage == null) return null;

      uiImage = await pdfImage.createImage();
      final bytes = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;

      final coversDir = await _coversDirectory();
      final baseName = preferredName ??
          p.basenameWithoutExtension(pdfPath).replaceAll(' ', '_');
      final coverPath = p.join(
        coversDir.path,
        '${DateTime.now().millisecondsSinceEpoch}_$baseName.png',
      );

      await File(coverPath).writeAsBytes(
        bytes.buffer.asUint8List(),
        flush: true,
      );
      return coverPath;
    } catch (_) {
      return null;
    } finally {
      uiImage?.dispose();
      pdfImage?.dispose();
      await document?.dispose();
    }
  }

  Future<String?> ensureCover(BookModel book) async {
    if (await _fileService.fileExists(book.coverPath)) {
      return book.coverPath;
    }

    final existing = _inFlight[book.id];
    if (existing != null) return existing;

    final future = _generateAndPersist(book);
    _inFlight[book.id] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(book.id);
    }
  }

  Future<String?> _generateAndPersist(BookModel book) async {
    final coverPath = await generateCover(
      book.filePath,
      preferredName: 'book_${book.id}',
    );
    if (coverPath == null) return null;

    try {
      await _bookRepo.updateCoverPath(book.id, coverPath);
    } catch (_) {
      // Cover file is still usable for this session even if DB update fails.
    }
    return coverPath;
  }

  Future<Directory> _coversDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'covers'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> deleteCover(String? coverPath) =>
      _fileService.deleteFileIfExists(coverPath);

  Future<void> clearAllCovers() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'covers'));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
