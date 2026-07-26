import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import 'glass_container.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: GlassContainer(
        borderRadius: 28.r,
        thickness: 5,
        blur: 5,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          children: [
            _NavItem(
              label: 'الرئيسية',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              selected: currentIndex == 0,
              onTap: () => onTap(0),
              accent: isDark ? AppColors.secondary : AppColors.primary,
            ),
            _NavItem(
              label: 'الأصناف',
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view_rounded,
              selected: currentIndex == 1,
              onTap: () => onTap(1),
              accent: isDark ? AppColors.secondary : AppColors.primary,
            ),
            _NavItem(
              label: 'المزيد',
              icon: Icons.more_horiz_rounded,
              selectedIcon: Icons.more_horiz_rounded,
              selected: currentIndex == 2,
              onTap: () => onTap(2),
              accent: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? accent : AppColors.neutralGray,
                size: 22.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? accent : AppColors.neutralGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
