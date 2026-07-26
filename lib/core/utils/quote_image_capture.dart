import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../errors/app_exception.dart';

abstract final class QuoteImageCapture {
  /// Captures a [RepaintBoundary] identified by [boundaryKey] as PNG bytes.
  static Future<Uint8List> capturePng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3,
  }) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      throw const AppException('تعذّر تجهيز صورة الاقتباس.');
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw const AppException('عنصر الصورة غير جاهز للمشاركة.');
    }

    try {
      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        throw const AppException('تعذّر إنشاء صورة الاقتباس.');
      }
      return bytes;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('تعذّر إنشاء صورة الاقتباس.', cause: e);
    }
  }
}
