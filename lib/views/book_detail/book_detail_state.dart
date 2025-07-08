import 'package:equatable/equatable.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/genre.dart';
import '../../models/review.dart';

abstract class BookDetailState extends Equatable {
  const BookDetailState();

  @override
  List<Object> get props => [];
}

class BookDetailInitial extends BookDetailState {}

// Khi trang vừa load, có thể hiển thị thông tin cơ bản từ Book được truyền vào
class BookDetailLoading extends BookDetailState {}

class BookDetailLoaded extends BookDetailState {
  final Book book;
  final List<Genre> genres;
  final List<Author> authors;
  final List<Review> reviews;
  final bool isLoadingRelatedData; // Rất quan trọng cho progressive loading
  final bool isFavorite; // MỚI: Trạng thái yêu thích
  final bool canAccess;
  final double averageRating;
  final int totalReviews;

  const BookDetailLoaded({
    required this.book,
    this.genres = const [],
    this.authors = const [],
    this.reviews = const [],
    this.isLoadingRelatedData = false, // Mặc định là false khi tải xong
    required this.isFavorite,
    required this.canAccess,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  BookDetailLoaded copyWith({
    Book? book,
    List<Genre>? genres,
    List<Author>? authors,
    List<Review>? reviews,
    bool? isLoadingRelatedData,
    bool? isFavorite,
    bool? canAccess,
    double? averageRating,
    int? totalReviews,
  }) {
    return BookDetailLoaded(
      book: book ?? this.book,
      genres: genres ?? this.genres,
      authors: authors ?? this.authors,
      reviews: reviews ?? this.reviews,
      isLoadingRelatedData: isLoadingRelatedData ?? this.isLoadingRelatedData,
      isFavorite: isFavorite ?? this.isFavorite,
      canAccess: canAccess ?? this.canAccess,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  @override
  List<Object> get props => [
        book,
        genres,
        authors,
        reviews,
        isLoadingRelatedData,
        isFavorite,
        canAccess,
        averageRating,
        totalReviews
      ];
}

/// MỚI: State thông báo hành động thành công
class BookDetailActionSuccess extends BookDetailState {
  final String message; // Thông báo cụ thể cho người dùng
  final String actionType; // Để phân biệt các loại hành động nếu cần

  const BookDetailActionSuccess({
    required this.message,
    this.actionType = 'general_success',
  });

  @override
  List<Object> get props => [message, actionType];
}

class BookDetailError extends BookDetailState {
  final String message;

  const BookDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
