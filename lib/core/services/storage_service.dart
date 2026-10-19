import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  bool get onboardingCompleted =>
      _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(StorageKeys.onboardingCompleted, value);

  String get themeMode => _prefs.getString(StorageKeys.themeMode) ?? 'system';

  Future<void> setThemeMode(String value) =>
      _prefs.setString(StorageKeys.themeMode, value);

  String get fontFamily =>
      _prefs.getString(StorageKeys.fontFamily) ?? 'qomra';

  Future<void> setFontFamily(String value) =>
      _prefs.setString(StorageKeys.fontFamily, value);

}
