import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controllers/more_controller.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المزيد',
          style: AppTextStyles.title.copyWith(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
        children: [
          Obx(() {
            final mode = controller.themeService.themeMode.value;
            return _MoreTile(
              icon: Icons.palette_outlined,
              title: 'المظهر',
              subtitle: controller.themeService.labelFor(mode),
              onTap: controller.openThemePicker,
            );
          }),
          _MoreTile(
            icon: Icons.dark_mode_outlined,
            title: 'الثيم',
            subtitle: 'تغيير الوضع الفاتح أو الداكن',
            onTap: controller.openThemePicker,
          ),
          _MoreTile(
            icon: Icons.done_all_rounded,
            title: 'الكتب المقروءة',
            subtitle: 'عرض الكتب التي أنهيتها',
            onTap: controller.openReadBooks,
          ),
          _MoreTile(
            icon: Icons.format_quote_rounded,
            title: 'اقتباساتي',
            subtitle: 'النصوص التي حفظتها أثناء القراءة',
            onTap: controller.openQuotes,
          ),
          _MoreTile(
            icon: Icons.recommend_outlined,
            title: 'التوصيات',
            subtitle: 'اقتراحات قرائية مختارة',
            onTap: controller.openRecommendations,
          ),
          _MoreTile(
            icon: Icons.library_books_outlined,
            title: 'مكتبات إلكترونية معروفة',
            subtitle: 'مصادر موثوقة للكتب',
            onTap: controller.openKnownLibraries,
          ),
          _MoreTile(
            icon: Icons.notifications_active_outlined,
            title: 'إعدادات التنبيهات',
            subtitle: 'تذكير يومي بالقراءة',
            onTap: controller.openNotifications,
          ),
          _MoreTile(
            icon: Icons.timer_outlined,
            title: 'مؤقت القراءة',
            subtitle: 'تتبّع وقت جلستك',
            onTap: controller.openReadingTimer,
          ),
          _MoreTile(
            icon: Icons.insights_outlined,
            title: 'الإحصائيات',
            subtitle: 'ملخص نشاطك القرائي',
            onTap: controller.openStatistics,
          ),
          _MoreTile(
            icon: Icons.settings_outlined,
            title: 'الإعدادات',
            subtitle: 'التفضيلات وإدارة البيانات',
            onTap: controller.openSettings,
          ),
          _MoreTile(
            icon: Icons.info_outline_rounded,
            title: 'حول التطبيق',
            subtitle: 'قيّم — رفيقك في رحلة القراءة',
            onTap: controller.openAbout,
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          leading: Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.secondary : AppColors.primary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ),
          title: Text(title, style: AppTextStyles.subtitle),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: AppColors.neutralGray),
          ),
          trailing: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.neutralGray,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}
