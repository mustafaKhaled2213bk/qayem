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

  bool get notificationEnabled =>
      _prefs.getBool(StorageKeys.notificationEnabled) ?? false;

  Future<void> setNotificationEnabled(bool value) =>
      _prefs.setBool(StorageKeys.notificationEnabled, value);

  int get dailyReminderHour =>
      _prefs.getInt(StorageKeys.dailyReminderHour) ?? 20;

  int get dailyReminderMinute =>
      _prefs.getInt(StorageKeys.dailyReminderMinute) ?? 0;

  Future<void> setDailyReminderTime(int hour, int minute) async {
    await _prefs.setInt(StorageKeys.dailyReminderHour, hour);
    await _prefs.setInt(StorageKeys.dailyReminderMinute, minute);
  }
}
