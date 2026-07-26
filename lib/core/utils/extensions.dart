import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../widgets/app_snackbar.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get cardColor =>
      isDark ? AppColors.cardDark : AppColors.cardLight;

  void showSnack(
    String message, {
    String title = 'تنبيه',
    AppSnackbarType type = AppSnackbarType.info,
  }) {
    AppSnackbar.show(title: title, message: message, type: type);
  }
}

extension StringX on String {
  String get fileNameWithoutExtension {
    final name = split(RegExp(r'[\\/]')).last;
    final dot = name.lastIndexOf('.');
    if (dot <= 0) return name;
    return name.substring(0, dot);
  }
}

extension IntX on int {
  double progressAgainst(int total) {
    if (total <= 0) return 0;
    final value = this / total;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }
}
