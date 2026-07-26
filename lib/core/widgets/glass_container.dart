import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../app/theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.thickness = 12,
    this.blur = 8,
    this.useFake = true,
  });

  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double thickness;
  final double blur;
  final bool useFake;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? 20.r;

    final content = Container(
      width: width,
      height: height,
      padding: padding,
      child: child,
    );

    final settings = LiquidGlassSettings(
      thickness: thickness,
      blur: blur,
      glassColor: isDark
          ? AppColors.cardDark.withValues(alpha: 0.35)
          : AppColors.white.withValues(alpha: 0.35),
      lightIntensity: isDark ? 0.4 : 0.7,
      refractiveIndex: 1.15,
    );

    return LiquidGlass.withOwnLayer(
      settings: settings,
      fake: useFake,
      shape: LiquidRoundedSuperellipse(borderRadius: radius),
      glassContainsChild: true,
      child: content,
    );
  }
}
