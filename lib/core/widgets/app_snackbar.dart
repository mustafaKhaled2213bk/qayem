import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_fonts.dart';

enum AppSnackbarType { success, error, info, warning }

abstract final class AppSnackbar {
  static void show({
    required String title,
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = _isDark;
    final colors = _colorsFor(type, isDark);

    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      borderRadius: 16,
      backgroundColor: colors.background,
      colorText: colors.foreground,
      titleText: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: AppFonts.active,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colors.foreground,
          height: 1.3,
        ),
      ),
      messageText: Text(
        message,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: AppFonts.active,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colors.foreground.withValues(alpha: 0.9),
          height: 1.45,
        ),
      ),
      icon: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsetsDirectional.only(end: 8),
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: isDark ? 0.22 : 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(colors.icon, color: colors.accent, size: 20),
      ),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      duration: duration,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      boxShadows: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: isDark ? 0.35 : 0.12),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      borderWidth: 1,
      borderColor: colors.border,
      overlayBlur: 0,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void success(String title, String message) => show(
        title: title,
        message: message,
        type: AppSnackbarType.success,
      );

  static void error(String title, String message) => show(
        title: title,
        message: message,
        type: AppSnackbarType.error,
        duration: const Duration(seconds: 4),
      );

  static void info(String title, String message) => show(
        title: title,
        message: message,
      );

  static void warning(String title, String message) => show(
        title: title,
        message: message,
        type: AppSnackbarType.warning,
      );

  static bool get _isDark {
    final context = Get.context;
    if (context != null) {
      return Theme.of(context).brightness == Brightness.dark;
    }
    return Get.isDarkMode;
  }

  static _SnackbarColors _colorsFor(AppSnackbarType type, bool isDark) {
    switch (type) {
      case AppSnackbarType.success:
        return _SnackbarColors(
          background: isDark ? const Color(0xFF1E2A22) : const Color(0xFFF1F7F2),
          foreground: isDark ? AppColors.white : AppColors.primary,
          accent: AppColors.success,
          border: AppColors.success.withValues(alpha: isDark ? 0.45 : 0.3),
          icon: Icons.check_circle_rounded,
        );
      case AppSnackbarType.error:
        return _SnackbarColors(
          background: isDark ? const Color(0xFF2A1C1C) : const Color(0xFFFFF3F3),
          foreground: isDark ? AppColors.white : const Color(0xFF5C1414),
          accent: AppColors.error,
          border: AppColors.error.withValues(alpha: isDark ? 0.45 : 0.28),
          icon: Icons.error_rounded,
        );
      case AppSnackbarType.warning:
        return _SnackbarColors(
          background: isDark ? const Color(0xFF2A2618) : const Color(0xFFFFF8E8),
          foreground: isDark ? AppColors.white : const Color(0xFF5C4500),
          accent: AppColors.warning,
          border: AppColors.warning.withValues(alpha: isDark ? 0.45 : 0.35),
          icon: Icons.warning_amber_rounded,
        );
      case AppSnackbarType.info:
        return _SnackbarColors(
          background: isDark ? AppColors.cardDark : AppColors.white,
          foreground: isDark ? AppColors.white : AppColors.primary,
          accent: isDark ? AppColors.secondary : AppColors.primary,
          border: (isDark ? AppColors.secondary : AppColors.primary)
              .withValues(alpha: isDark ? 0.35 : 0.18),
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackbarColors {
  const _SnackbarColors({
    required this.background,
    required this.foreground,
    required this.accent,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color accent;
  final Color border;
  final IconData icon;
}
