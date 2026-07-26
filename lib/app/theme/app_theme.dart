import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppFonts.cairo,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceLight,
          error: AppColors.error,
          onPrimary: AppColors.white,
          onSecondary: AppColors.primary,
          onSurface: AppColors.textPrimaryLight,
          onError: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        cardColor: AppColors.cardLight,
        dividerColor: AppColors.neutralGray.withValues(alpha: 0.25),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.cairo,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.white.withValues(alpha: 0.85),
          indicatorColor: AppColors.secondary.withValues(alpha: 0.35),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontFamily: AppFonts.cairo,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.neutralGray,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.primary : AppColors.neutralGray,
              size: 24,
            );
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: AppFonts.cairo,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            textStyle: const TextStyle(
              fontFamily: AppFonts.cairo,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontFamily: AppFonts.cairo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          hintStyle: const TextStyle(
            fontFamily: AppFonts.cairo,
            color: AppColors.neutralGray,
          ),
          labelStyle: const TextStyle(
            fontFamily: AppFonts.cairo,
            color: AppColors.neutralGray,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: AppFonts.cairo,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: AppColors.white,
          contentTextStyle: const TextStyle(
            fontFamily: AppFonts.cairo,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
          actionTextColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
          insetPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
        textTheme: _textTheme(
          AppColors.textPrimaryLight,
          AppColors.textSecondaryLight,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppFonts.cairo,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.secondary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
          onPrimary: AppColors.primary,
          onSecondary: AppColors.primary,
          onSurface: AppColors.textPrimaryDark,
          onError: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        cardColor: AppColors.cardDark,
        dividerColor: AppColors.neutralGray.withValues(alpha: 0.2),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.cairo,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDark,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.primary,
          elevation: 2,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.9),
          indicatorColor: AppColors.secondary.withValues(alpha: 0.25),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontFamily: AppFonts.cairo,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.secondary : AppColors.neutralGray,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.secondary : AppColors.neutralGray,
              size: 24,
            );
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.primary,
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: AppFonts.cairo,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: const BorderSide(color: AppColors.secondary),
            textStyle: const TextStyle(
              fontFamily: AppFonts.cairo,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            textStyle: const TextStyle(
              fontFamily: AppFonts.cairo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardDark,
          hintStyle: const TextStyle(
            fontFamily: AppFonts.cairo,
            color: AppColors.neutralGray,
          ),
          labelStyle: const TextStyle(
            fontFamily: AppFonts.cairo,
            color: AppColors.neutralGray,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.secondary.withValues(alpha: 0.25),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.secondary.withValues(alpha: 0.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.secondary,
              width: 1.5,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.secondary.withValues(alpha: 0.12),
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: AppFonts.cairo,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: AppColors.cardDark,
          contentTextStyle: const TextStyle(
            fontFamily: AppFonts.cairo,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          actionTextColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.secondary.withValues(alpha: 0.22),
            ),
          ),
          insetPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.secondary,
        ),
        textTheme: _textTheme(
          AppColors.textPrimaryDark,
          AppColors.textSecondaryDark,
        ),
      );

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(fontFamily: AppFonts.cairo, color: primary),
      bodyMedium: TextStyle(fontFamily: AppFonts.cairo, color: primary),
      bodySmall: TextStyle(fontFamily: AppFonts.cairo, color: secondary),
      labelLarge: TextStyle(
        fontFamily: AppFonts.cairo,
        color: primary,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(fontFamily: AppFonts.cairo, color: secondary),
      labelSmall: TextStyle(fontFamily: AppFonts.cairo, color: secondary),
    );
  }
}
