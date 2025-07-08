import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Review extends Equatable {
  final String reviewId;
  final String userId;
  final String bookId;
  final int rating; // 1 to 5 stars
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.reviewId,
    required this.userId,
    required this.bookId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      // Ưu tiên camelCase, sau đó là snake_case
      reviewId: json['reviewId'] as String? ?? json['review_id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String,
      bookId: json['bookId'] as String? ?? json['book_id'] as String,
      rating: json['rating'] as int, // 'rating' đã là camelCase
      comment: json['comment'] as String?, // 'comment' đã là camelCase
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Xuất ra camelCase (giả sử API backend của bạn đã hỗ trợ camelCase)
      'reviewId': reviewId.isEmpty ? const Uuid().v4() : reviewId, // Đổi từ 'review_id'
      'userId': userId, // Đổi từ 'user_id'
      'bookId': bookId, // Đổi từ 'book_id'
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(), // Đổi từ 'created_at'
    };
  }

  Review copyWith({
    String? reviewId,
    String? userId,
    String? bookId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      reviewId: reviewId ?? this.reviewId,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    reviewId,
    userId,
    bookId,
    rating,
    comment,
    createdAt,
  ];
}