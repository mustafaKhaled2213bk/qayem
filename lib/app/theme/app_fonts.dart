enum AppFontFamily {
  qomra,
  cairo,
  system;

  String get arabicName {
    switch (this) {
      case AppFontFamily.qomra:
        return 'قمرة';
      case AppFontFamily.cairo:
        return 'القاهرة';
      case AppFontFamily.system:
        return 'الخط العادي';
    }
  }

  /// Null means the platform default font.
  String? get familyName {
    switch (this) {
      case AppFontFamily.qomra:
        return AppFonts.qomra;
      case AppFontFamily.cairo:
        return AppFonts.cairo;
      case AppFontFamily.system:
        return null;
    }
  }

  String get storageKey {
    switch (this) {
      case AppFontFamily.qomra:
        return 'qomra';
      case AppFontFamily.cairo:
        return 'cairo';
      case AppFontFamily.system:
        return 'system';
    }
  }

  static AppFontFamily fromStorage(String? value) {
    switch (value) {
      case 'cairo':
        return AppFontFamily.cairo;
      case 'system':
        return AppFontFamily.system;
      case 'qomra':
      default:
        return AppFontFamily.qomra;
    }
  }
}

abstract final class AppFonts {
  static const String cairo = 'Cairo';
  static const String qomra = 'Qomra';

  /// Current UI font family. Null uses the platform default.
  static String? active = qomra;
}
