import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../errors/app_exception.dart';
import '../utils/extensions.dart';

class PickedPdfResult {
  const PickedPdfResult({
    required this.sourcePath,
    required this.fileName,
    required this.title,
  });

  final String sourcePath;
  final String fileName;
  final String title;
}

class FileService {
  Future<PickedPdfResult?> pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final path = file.path;
    if (path == null || path.isEmpty) {
      throw const FileException('تعذّر الوصول إلى مسار الملف المحدد.');
    }

    final source = File(path);
    if (!await source.exists()) {
      throw const FileException('الملف المحدد غير موجود.');
    }

    final lower = path.toLowerCase();
    if (!lower.endsWith('.pdf')) {
      throw const FileException('يجب اختيار ملف PDF فقط.');
    }

    final fileName = file.name;
    return PickedPdfResult(
      sourcePath: path,
      fileName: fileName,
      title: fileName.fileNameWithoutExtension,
    );
  }

  Future<String> persistPdf(String sourcePath, {required String title}) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileException('ملف PDF غير موجود.');
    }

    final docs = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(docs.path, 'books'));
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }

    final safeTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${safeTitle.isEmpty ? 'book' : safeTitle}.pdf';
    final destination = p.join(booksDir.path, fileName);
    await source.copy(destination);
    return destination;
  }

  Future<bool> fileExists(String? path) async {
    if (path == null || path.isEmpty) return false;
    return File(path).exists();
  }

  Future<void> deleteFileIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
