import '../data/app_data.dart';
import '../models/reading_progress.dart';

class ReadingProgressController {
  Future<ReadingProgress> addBookmark({
    required String bookId,
    String? chapterTitle,
    int? chapterNumber,
    int? paragraphNumber,
    String? cfi,
    double? audioProgressSeconds,
    bool? completed,
  }) async {
    try {
      final result = await AppData().readingProgress.addBookmark(
            bookId,
            chapterTitle: chapterTitle,
            chapterNumber: chapterNumber,
            paragraphNumber: paragraphNumber,
            cfi: cfi,
            audioProgressSeconds: audioProgressSeconds,
            completed: completed,
          );
      return ReadingProgress.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      print('Error adding bookmark for book ID $bookId: $e');
      rethrow;
    }
  }

  Future<List<ReadingProgress>> fetchBookmarksForBook(
    String bookId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await AppData().readingProgress.fetchUserBookBookmark(
            bookId,
            limit: limit,
            offset: offset,
          );
      return List<ReadingProgress>.from(result
          .map((x) => ReadingProgress.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching bookmarks for book ID $bookId: $e');
      rethrow;
    }
  }

  Future<ReadingProgress> deleteBookmark(String progressId) async {
    try {
      final result = await AppData().readingProgress.deleteBookmark(progressId);
      return ReadingProgress.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      print('Error deleting bookmark $progressId: $e');
      rethrow;
    }
  }
}
