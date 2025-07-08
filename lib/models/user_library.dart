import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum AccessSource { purchased, premiumSubscription, free } // Đổi tên cho hợp lý

class UserLibrary extends Equatable {
  final String userLibraryId;
  final String userId;
  final String bookId;
  final DateTime addedAt;
  final bool isFavorited;
  final AccessSource? accessSource; // Nullable if only favorited
  final String? transactionId; // References PaymentTransaction.transactionId if purchased

  const UserLibrary({
    required this.userLibraryId,
    required this.userId,
    required this.bookId,
    required this.addedAt,
    this.isFavorited = false,
    this.accessSource,
    this.transactionId,
  });

  factory UserLibrary.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse enum from string, trying camelCase then snake_case
    T? _parseNullableEnum<T extends Enum>(Map<String, dynamic> json, String camelKey, String snakeKey, List<T> values) {
      final String? value = json[camelKey] as String? ?? json[snakeKey] as String?;
      if (value == null) {
        return null;
      }
      return values.firstWhere(
            (e) => e.toString().split('.').last == value,
        orElse: () => throw ArgumentError('Unknown enum value: $value for $camelKey/$snakeKey'), // Hoặc một giá trị mặc định nếu phù hợp
      );
    }

    return UserLibrary(
      // Ưu tiên camelCase, sau đó là snake_case
      userLibraryId: json['userLibraryId'] as String? ?? json['user_book_id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String,
      bookId: json['bookId'] as String? ?? json['book_id'] as String,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.parse(json['added_at'] as String),
      isFavorited: json['isFavorited'] as bool? ?? json['is_favorited'] as bool,
      accessSource: _parseNullableEnum(json, 'accessSource', 'access_source', AccessSource.values),
      transactionId: json['transactionId'] as String? ?? json['transaction_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Xuất ra camelCase (giả sử API backend của bạn đã hỗ trợ camelCase)
      'userLibraryId': userLibraryId.isEmpty ? const Uuid().v4() : userLibraryId, // Đổi từ 'user_book_id'
      'userId': userId, // Đổi từ 'user_id'
      'bookId': bookId, // Đổi từ 'book_id'
      'addedAt': addedAt.toIso8601String(), // Đổi từ 'added_at'
      'isFavorited': isFavorited, // Đổi từ 'is_favorited'
      'accessSource': accessSource?.toString().split('.').last,
      'transactionId': transactionId, // Đổi từ 'transaction_id'
    };
  }

  UserLibrary copyWith({
    String? userLibraryId,
    String? userId,
    String? bookId,
    DateTime? addedAt,
    bool? isFavorited,
    AccessSource? accessSource,
    String? transactionId,
  }) {
    return UserLibrary(
      userLibraryId: userLibraryId ?? this.userLibraryId,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      addedAt: addedAt ?? this.addedAt,
      isFavorited: isFavorited ?? this.isFavorited,
      accessSource: accessSource ?? this.accessSource,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  List<Object?> get props => [
    userLibraryId,
    userId,
    bookId,
    addedAt,
    isFavorited,
    accessSource,
    transactionId,
  ];
}