enum ReminderGoalPeriod {
  daily,
  weekly;

  String get dbValue => name;

  String get labelAr => switch (this) {
        ReminderGoalPeriod.daily => 'يومي',
        ReminderGoalPeriod.weekly => 'أسبوعي',
      };

  static ReminderGoalPeriod fromDb(String? value) {
    return ReminderGoalPeriod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReminderGoalPeriod.daily,
    );
  }
}

class BookReminderModel {
  const BookReminderModel({
    required this.id,
    required this.bookId,
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.goalMinutes,
    required this.goalPeriod,
    required this.createdAt,
    required this.updatedAt,
    this.bookTitle,
  });

  final int id;
  final int bookId;
  final bool enabled;
  final int hour;
  final int minute;
  final int goalMinutes;
  final ReminderGoalPeriod goalPeriod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bookTitle;

  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Soft daily share used for home aggregate (weekly → minutes / 7).
  int get dailyShareMinutes => switch (goalPeriod) {
        ReminderGoalPeriod.daily => goalMinutes,
        ReminderGoalPeriod.weekly => (goalMinutes / 7).ceil().clamp(1, goalMinutes),
      };

  BookReminderModel copyWith({
    int? id,
    int? bookId,
    bool? enabled,
    int? hour,
    int? minute,
    int? goalMinutes,
    ReminderGoalPeriod? goalPeriod,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bookTitle,
  }) {
    return BookReminderModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      goalMinutes: goalMinutes ?? this.goalMinutes,
      goalPeriod: goalPeriod ?? this.goalPeriod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookTitle: bookTitle ?? this.bookTitle,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id == 0 ? null : id,
      'book_id': bookId,
      'enabled': enabled ? 1 : 0,
      'hour': hour,
      'minute': minute,
      'goal_minutes': goalMinutes,
      'goal_period': goalPeriod.dbValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BookReminderModel.fromMap(Map<String, Object?> map) {
    return BookReminderModel(
      id: map['id'] as int? ?? 0,
      bookId: map['book_id'] as int? ?? 0,
      enabled: (map['enabled'] as int? ?? 1) == 1,
      hour: map['hour'] as int? ?? 20,
      minute: map['minute'] as int? ?? 0,
      goalMinutes: map['goal_minutes'] as int? ?? 20,
      goalPeriod: ReminderGoalPeriod.fromDb(map['goal_period'] as String?),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
      bookTitle: map['book_title'] as String?,
    );
  }
}
