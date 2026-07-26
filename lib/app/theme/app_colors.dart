import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF042623);
  static const Color secondary = Color(0xFFB9A779);
  static const Color lightGray = Color(0xFFFAFAFA);
  static const Color neutralGray = Color(0xFF9E9E9E);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static const Color backgroundLight = lightGray;
  static const Color surfaceLight = white;
  static const Color cardLight = white;
  static const Color textPrimaryLight = black;
  static const Color textSecondaryLight = neutralGray;

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1C1C1C);
  static const Color cardDark = Color(0xFF242424);
  static const Color textPrimaryDark = white;
  static const Color textSecondaryDark = neutralGray;

  static const Color error = Color(0xFFC62828);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);

  static const List<Color> categoryPalette = [
    Color(0xFF042623),
    Color(0xFFB9A779),
    Color(0xFF1B4D3E),
    Color(0xFF6B8E6B),
    Color(0xFF8B6914),
    Color(0xFF4A6741),
    Color(0xFF2C5F5D),
    Color(0xFF7A6B4F),
  ];
}
