import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class ReadingProgress extends Equatable {
  final String progressId;
  final String userId;
  final String bookId;
  final String? chapterTitle;
  final int? chapterNumber;
  final int? paragraphNumber;
  final String? cfi;
  final double? audioProgressSeconds;
  final bool completed;

  const ReadingProgress({
    required this.progressId,
    required this.userId,
    required this.bookId,
    this.chapterTitle,
    this.chapterNumber,
    this.paragraphNumber,
    this.cfi,
    this.audioProgressSeconds,
    required this.completed,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      progressId: json['progressId'] as String? ?? json['progress_id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String,
      bookId: json['bookId'] as String? ?? json['book_id'] as String,
      chapterTitle: json['chapterTitle'] as String? ?? json['chapter_title'] as String?,
      chapterNumber: json['chapterNumber'] as int? ?? json['chapter_number'] as int?,
      paragraphNumber: json['paragraphNumber'] as int? ?? json['paragraph_number'] as int?,
      cfi: json['cfi'] as String?,
      audioProgressSeconds: json['audioProgressSeconds'] as double? ?? json['audio_progress_seconds'] as double?,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progressId': progressId.isEmpty ? const Uuid().v4() : progressId,
      'userId': userId,
      'bookId': bookId,
      'chapterTitle': chapterTitle,
      'chapterNumber': chapterNumber,
      'paragraphNumber': paragraphNumber,
      'cfi': cfi,
      'audioProgressSeconds': audioProgressSeconds,
      'completed': completed,
    };
  }

  ReadingProgress copyWith({
    String? progressId,
    String? userId,
    String? bookId,
    String? chapterTitle,
    int? chapterNumber,
    int? paragraphNumber,
    String? cfi,
    double? audioProgressSeconds,
    bool? completed,
  }) {
    return ReadingProgress(
      progressId: progressId ?? this.progressId,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      paragraphNumber: paragraphNumber ?? this.paragraphNumber,
      cfi: cfi ?? this.cfi,
      audioProgressSeconds: audioProgressSeconds ?? this.audioProgressSeconds,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [
    progressId,
    userId,
    bookId,
    chapterTitle,
    chapterNumber,
    paragraphNumber,
    cfi,
    audioProgressSeconds,
    completed,
  ];
}