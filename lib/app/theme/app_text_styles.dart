import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle get displayLarge => TextStyle(
        fontFamily: AppFonts.active,
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: AppFonts.active,
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headline => TextStyle(
        fontFamily: AppFonts.active,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        height: 1.35,
      );

  static TextStyle get title => TextStyle(
        fontFamily: AppFonts.active,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get subtitle => TextStyle(
        fontFamily: AppFonts.active,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get body => TextStyle(
        fontFamily: AppFonts.active,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: AppFonts.active,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get button => TextStyle(
        fontFamily: AppFonts.active,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
}
