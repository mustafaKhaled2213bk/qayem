import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../controllers/statistics_controller.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingState();
        }
        if (controller.errorMessage.value.isNotEmpty ||
            controller.stats.value == null) {
          return EmptyState(
            title: 'تعذّر التحميل',
            subtitle: controller.errorMessage.value,
            actionLabel: 'إعادة المحاولة',
            onAction: controller.load,
          );
        }

        final s = controller.stats.value!;
        return GridView.count(
          padding: EdgeInsets.all(16.w),
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.15,
          children: [
            _StatCard(
              title: 'إجمالي الكتب',
              value: '${s.totalBooks}',
              icon: Icons.menu_book_rounded,
            ),
            _StatCard(
              title: 'كتب مكتملة',
              value: '${s.completedBooks}',
              icon: Icons.done_all_rounded,
            ),
            _StatCard(
              title: 'قيد القراءة',
              value: '${s.currentlyReading}',
              icon: Icons.auto_stories_rounded,
            ),
            _StatCard(
              title: 'وقت القراءة',
              value: DateFormatter.formatDuration(s.totalReadingTime),
              icon: Icons.timer_rounded,
            ),
            _StatCard(
              title: 'صفحات مقروءة',
              value: '${s.pagesRead}',
              icon: Icons.filter_none_rounded,
            ),
          ],
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.secondary : AppColors.primary,
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.headline),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.neutralGray,
            ),
          ),
        ],
      ),
    );
  }
}
