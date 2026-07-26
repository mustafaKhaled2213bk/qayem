class ReadingSessionModel {
  const ReadingSessionModel({
    required this.id,
    required this.bookId,
    required this.startTime,
    required this.duration,
    this.endTime,
  });

  final int id;
  final int bookId;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;

  Map<String, Object?> toMap() {
    return {
      'id': id == 0 ? null : id,
      'book_id': bookId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration': duration,
    };
  }

  factory ReadingSessionModel.fromMap(Map<String, Object?> map) {
    return ReadingSessionModel(
      id: map['id'] as int? ?? 0,
      bookId: map['book_id'] as int? ?? 0,
      startTime: DateTime.tryParse(map['start_time'] as String? ?? '') ??
          DateTime.now(),
      endTime: DateTime.tryParse(map['end_time'] as String? ?? ''),
      duration: map['duration'] as int? ?? 0,
    );
  }
}
