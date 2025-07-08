import 'package:equatable/equatable.dart';

import '../../models/book.dart';

abstract class BookDetailEvent extends Equatable {
  const BookDetailEvent();

  @override
  List<Object> get props => [];
}

// Event để tải dữ liệu liên quan sau khi có Book object cơ bản
class LoadBookDetailRelatedData extends BookDetailEvent {
  final Book book; // Cần bookId để tải dữ liệu liên quan

  const LoadBookDetailRelatedData({required this.book});

  @override
  List<Object> get props => [book];
}

class ToggleFavoriteEvent extends BookDetailEvent {
  const ToggleFavoriteEvent();
}

class CreateReviewEvent extends BookDetailEvent {
  final String bookId;
  final int rating;
  final String comment;

  const CreateReviewEvent({
    required this.bookId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object> get props => [bookId, rating, comment];
}

class UpdateReviewEvent extends BookDetailEvent {
  final String reviewId;
  final int rating;
  final String comment;

  const UpdateReviewEvent({
    required this.reviewId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object> get props => [reviewId, rating, comment];
}

class DeleteReviewEvent extends BookDetailEvent {
  final String reviewId;

  const DeleteReviewEvent({
    required this.reviewId,
  });

  @override
  List<Object> get props => [reviewId];
}