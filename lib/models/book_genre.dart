import 'package:equatable/equatable.dart';

class BookGenre extends Equatable {
  final String bookId;
  final String genreId;

  const BookGenre({
    required this.bookId,
    required this.genreId,
  });

  factory BookGenre.fromJson(Map<String, dynamic> json) {
    return BookGenre(
      bookId: json['bookId'] as String? ?? json['book_id'] as String,
      genreId: json['genreId'] as String? ?? json['genre_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'genreId': genreId,
    };
  }

  BookGenre copyWith({
    String? bookId,
    String? genreId,
  }) {
    return BookGenre(
      bookId: bookId ?? this.bookId,
      genreId: genreId ?? this.genreId,
    );
  }

  @override
  List<Object?> get props => [bookId, genreId];
}