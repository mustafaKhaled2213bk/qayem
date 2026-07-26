import 'package:flutter/material.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: 'مرحباً بك في قيّم',
      description: 'رفيقك في رحلة القراءة.',
      icon: Icons.menu_book_rounded,
    ),
    OnboardingPageData(
      title: 'نظّم كتبك بسهولة',
      description: 'أضف ملفات PDF وصنّفها بالطريقة التي تناسبك.',
      icon: Icons.folder_special_rounded,
    ),
    OnboardingPageData(
      title: 'تابع تقدمك بكل مرونة',
      description:
          'سنحفظ آخر صفحة وصلت إليها لتعود إلى القراءة من حيث توقفت.',
      icon: Icons.bookmark_added_rounded,
    ),
    OnboardingPageData(
      title: 'اجعل القراءة عادة يومية',
      description: 'استخدم مؤقت القراءة واضبط تذكيرات يومية للقراءة.',
      icon: Icons.timer_rounded,
    ),
  ];
}
