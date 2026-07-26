class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.categoryId,
    required this.currentPage,
    required this.totalPages,
    required this.progress,
    required this.createdAt,
    required this.isCompleted,
    required this.totalReadingTime,
    this.coverPath,
    this.lastOpenedAt,
    this.categoryName,
    this.categoryColor,
  });

  final int id;
  final String title;
  final String filePath;
  final int categoryId;
  final String? coverPath;
  final int currentPage;
  final int totalPages;
  final double progress;
  final DateTime createdAt;
  final DateTime? lastOpenedAt;
  final bool isCompleted;
  final int totalReadingTime;
  final String? categoryName;
  final int? categoryColor;

  int get progressPercent => (progress * 100).clamp(0, 100).round();

  BookModel copyWith({
    int? id,
    String? title,
    String? filePath,
    int? categoryId,
    String? coverPath,
    int? currentPage,
    int? totalPages,
    double? progress,
    DateTime? createdAt,
    DateTime? lastOpenedAt,
    bool? isCompleted,
    int? totalReadingTime,
    String? categoryName,
    int? categoryColor,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      categoryId: categoryId ?? this.categoryId,
      coverPath: coverPath ?? this.coverPath,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id == 0 ? null : id,
      'title': title,
      'file_path': filePath,
      'category_id': categoryId,
      'cover_path': coverPath,
      'current_page': currentPage,
      'total_pages': totalPages,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      'last_opened_at': lastOpenedAt?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'total_reading_time': totalReadingTime,
    };
  }

  factory BookModel.fromMap(Map<String, Object?> map) {
    return BookModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      filePath: map['file_path'] as String? ?? '',
      categoryId: map['category_id'] as int? ?? 0,
      coverPath: map['cover_path'] as String?,
      currentPage: map['current_page'] as int? ?? 1,
      totalPages: map['total_pages'] as int? ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      lastOpenedAt: DateTime.tryParse(map['last_opened_at'] as String? ?? ''),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      totalReadingTime: map['total_reading_time'] as int? ?? 0,
      categoryName: map['category_name'] as String?,
      categoryColor: map['category_color'] as int?,
    );
  }
}
