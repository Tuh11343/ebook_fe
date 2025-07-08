import 'package:equatable/equatable.dart';

class BookAuthor extends Equatable {
  final String bookId;
  final String authorId;

  const BookAuthor({
    required this.bookId,
    required this.authorId,
  });

  factory BookAuthor.fromJson(Map<String, dynamic> json) {
    return BookAuthor(
      bookId: json['bookId'] as String? ?? json['book_id'] as String,
      authorId: json['authorId'] as String? ?? json['author_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'authorId': authorId,
    };
  }

  BookAuthor copyWith({
    String? bookId,
    String? authorId,
  }) {
    return BookAuthor(
      bookId: bookId ?? this.bookId,
      authorId: authorId ?? this.authorId,
    );
  }

  @override
  List<Object?> get props => [bookId, authorId];
}