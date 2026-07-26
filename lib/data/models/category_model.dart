import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.bookCount = 0,
  });

  final int id;
  final String name;
  final String icon;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int bookCount;

  Color get color => Color(colorValue);

  IconData get iconData => categoryIconFromKey(icon);

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? bookCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookCount: bookCount ?? this.bookCount,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id == 0 ? null : id,
      'name': name,
      'icon': icon,
      'color': colorValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, Object?> map) {
    return CategoryModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      icon: map['icon'] as String? ?? 'folder',
      colorValue: map['color'] as int? ?? 0xFF042623,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
      bookCount: map['book_count'] as int? ?? 0,
    );
  }
}

IconData categoryIconFromKey(String key) {
  switch (key) {
    case 'menu_book':
      return Icons.menu_book_rounded;
    case 'science':
      return Icons.science_rounded;
    case 'psychology':
      return Icons.psychology_rounded;
    case 'account_balance':
      return Icons.account_balance_rounded;
    case 'work':
      return Icons.work_rounded;
    case 'favorite':
      return Icons.favorite_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'school':
      return Icons.school_rounded;
    case 'code':
      return Icons.code_rounded;
    case 'public':
      return Icons.public_rounded;
    case 'auto_stories':
      return Icons.auto_stories_rounded;
    default:
      return Icons.folder_rounded;
  }
}

const List<String> categoryIconKeys = [
  'menu_book',
  'auto_stories',
  'science',
  'psychology',
  'account_balance',
  'school',
  'work',
  'favorite',
  'star',
  'code',
  'public',
  'folder',
];
