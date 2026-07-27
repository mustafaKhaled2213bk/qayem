import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.onLongPress,
  });

  final CategoryModel category;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = category.color;
    final radius = BorderRadius.circular(20.r);

    final surface = isDark ? AppColors.cardDark : AppColors.white;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: surface),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          accent.withValues(alpha: isDark ? 0.22 : 0.14),
                          accent.withValues(alpha: isDark ? 0.06 : 0.03),
                          surface.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.45, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -28.h,
                  left: -18.w,
                  child: _BlurOrb(
                    size: 92.w,
                    color: accent.withValues(alpha: isDark ? 0.38 : 0.28),
                    blur: 28,
                  ),
                ),
                Positioned(
                  bottom: -34.h,
                  right: -22.w,
                  child: _BlurOrb(
                    size: 110.w,
                    color: accent.withValues(alpha: isDark ? 0.28 : 0.18),
                    blur: 32,
                  ),
                ),
                Positioned(
                  top: 36.h,
                  right: -16.w,
                  child: _BlurOrb(
                    size: 56.w,
                    color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
                    blur: 18,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: accent.withValues(alpha: isDark ? 0.28 : 0.18),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 52.w,
                          height: 52.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent.withValues(alpha: isDark ? 0.4 : 0.22),
                                accent.withValues(alpha: isDark ? 0.18 : 0.1),
                              ],
                            ),
                            border: Border.all(
                              color: accent.withValues(
                                alpha: isDark ? 0.45 : 0.22,
                              ),
                            ),
                          ),
                          child: Icon(
                            category.iconData,
                            color: isDark
                                ? Color.lerp(accent, Colors.white, 0.35)!
                                : accent,
                            size: 26.sp,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${category.bookCount} كتاب',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? Color.lerp(accent, Colors.white, 0.5)!
                              : accent.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddCategoryCard extends StatelessWidget {
  const AddCategoryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondary : AppColors.primary;
    final radius = BorderRadius.circular(20.r);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: accent.withValues(alpha: isDark ? 0.45 : 0.28),
            radius: 20.r,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: accent.withValues(alpha: isDark ? 0.08 : 0.04),
                  ),
                ),
                Positioned(
                  top: -20.h,
                  right: -12.w,
                  child: _BlurOrb(
                    size: 72.w,
                    color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                    blur: 22,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                          border: Border.all(
                            color: accent.withValues(
                              alpha: isDark ? 0.4 : 0.22,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 28.sp,
                          color: accent,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'إضافة صنف جديد',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.size,
    required this.color,
    required this.blur,
  });

  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: blur,
        sigmaY: blur,
        tileMode: TileMode.decal,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
