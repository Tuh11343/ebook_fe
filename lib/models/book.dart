import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum BookType { ebook, audiobook }
enum AccessType { free, premium, purchase }

class Book extends Equatable {
  final String bookId;
  final String title;
  final String description;
  final String? coverImageUrl;
  final BookType bookType;
  final AccessType accessType;
  final double? price;
  final String? fileUrl;
  final int? pages;
  final String? audioFileUrl;
  final int? durationMinutes;
  final DateTime? publishedDate;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Book({
    required this.bookId,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.bookType,
    required this.accessType,
    this.price,
    this.fileUrl,
    this.pages,
    this.audioFileUrl,
    this.durationMinutes,
    this.publishedDate,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    T _parseEnum<T extends Enum>(Map<String, dynamic> json, String camelKey, String snakeKey, List<T> values) {
      final String? value = json[camelKey] as String? ?? json[snakeKey] as String?;
      if (value == null) {
        throw ArgumentError('Required enum value not found for $camelKey or $snakeKey');
      }
      return values.firstWhere((e) => e.toString().split('.').last == value);
    }

    return Book(
      bookId: json['bookId'] as String? ?? json['book_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String? ?? json['cover_image_url'] as String?,

      bookType: _parseEnum(json, 'bookType', 'book_type', BookType.values),
      accessType: _parseEnum(json, 'accessType', 'access_type', AccessType.values),

      price: (json['price'] as num?)?.toDouble(),
      fileUrl: json['fileUrl'] as String? ?? json['file_url'] as String?,
      pages: json['pages'] as int?,
      audioFileUrl: json['audioFileUrl'] as String? ?? json['audio_file_url'] as String?,
      durationMinutes: json['durationMinutes'] as int? ?? json['duration_minutes'] as int?,
      publishedDate: json['publishedDate'] != null
          ? DateTime.parse(json['publishedDate'] as String)
          : (json['published_date'] != null
          ? DateTime.parse(json['published_date'] as String)
          : null),
      language: json['language'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId.isEmpty ? const Uuid().v4() : bookId,
      'title': title,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'bookType': bookType.toString().split('.').last,
      'accessType': accessType.toString().split('.').last,
      'price': price,
      'fileUrl': fileUrl,
      'pages': pages,
      'audioFileUrl': audioFileUrl,
      'durationMinutes': durationMinutes,
      'publishedDate': publishedDate?.toIso8601String().split('T').first,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Book copyWith({
    String? bookId,
    String? title,
    String? description,
    String? coverImageUrl,
    BookType? bookType,
    AccessType? accessType,
    double? price,
    String? fileUrl,
    int? pages,
    String? audioFileUrl,
    int? durationMinutes,
    DateTime? publishedDate,
    double? averageRating,
    int? totalReviews,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      bookType: bookType ?? this.bookType,
      accessType: accessType ?? this.accessType,
      price: price ?? this.price,
      fileUrl: fileUrl ?? this.fileUrl,
      pages: pages ?? this.pages,
      audioFileUrl: audioFileUrl ?? this.audioFileUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      publishedDate: publishedDate ?? this.publishedDate,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    bookId,
    title,
    description,
    coverImageUrl,
    bookType,
    accessType,
    price,
    fileUrl,
    pages,
    audioFileUrl,
    durationMinutes,
    publishedDate,
    language,
    createdAt,
    updatedAt,
  ];
}