import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_fonts.dart';
import 'storage_service.dart';

class ThemeService extends GetxService {
  ThemeService(this._storage);

  final StorageService _storage;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final Rx<AppFontFamily> fontFamily = AppFontFamily.qomra.obs;

  @override
  void onInit() {
    super.onInit();
    final mode = _parse(_storage.themeMode);
    themeMode.value = mode;
    Get.changeThemeMode(mode);

    final font = AppFontFamily.fromStorage(_storage.fontFamily);
    fontFamily.value = font;
    AppFonts.active = font.familyName;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _storage.setThemeMode(_serialize(mode));
  }

  Future<void> setFontFamily(AppFontFamily font) async {
    fontFamily.value = font;
    AppFonts.active = font.familyName;
    await _storage.setFontFamily(font.storageKey);
  }

  ThemeMode _parse(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  String labelFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'حسب النظام';
    }
  }

  String labelForFont(AppFontFamily font) => font.arabicName;
}
