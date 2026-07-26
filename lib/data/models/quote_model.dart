class QuoteModel {
  const QuoteModel({
    required this.id,
    required this.bookId,
    required this.pageNumber,
    required this.content,
    required this.createdAt,
    this.bookTitle,
  });

  final int id;
  final int bookId;
  final int pageNumber;
  final String content;
  final DateTime createdAt;
  final String? bookTitle;

  QuoteModel copyWith({
    int? id,
    int? bookId,
    int? pageNumber,
    String? content,
    DateTime? createdAt,
    String? bookTitle,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      pageNumber: pageNumber ?? this.pageNumber,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      bookTitle: bookTitle ?? this.bookTitle,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id == 0 ? null : id,
      'book_id': bookId,
      'page_number': pageNumber,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory QuoteModel.fromMap(Map<String, Object?> map) {
    return QuoteModel(
      id: map['id'] as int? ?? 0,
      bookId: map['book_id'] as int? ?? 0,
      pageNumber: map['page_number'] as int? ?? 1,
      content: map['content'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      bookTitle: map['book_title'] as String?,
    );
  }
}
