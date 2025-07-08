import '../data/app_data.dart';
import '../models/review.dart';

class ReviewController {

  Future<Map<String, dynamic>> fetchReviewsAndStatsByBookId(String bookId) async {
    try {
      final result = await AppData().review.getReviewsAndStatsByBookId(bookId);
      return result;
    } catch (e) {
      print('Error fetching reviews and stats for book $bookId: $e');
      rethrow;
    }
  }

  Future<Review> createReview(String bookId, int rating, String? comment) async {
    try {
      final newReview = await AppData().review.createReview(bookId, rating, comment);
      return newReview;
    } catch (e) {
      print('Error creating review for book $bookId: $e');
      rethrow;
    }
  }

  Future<Review> updateReview(String reviewId, int? rating, String? comment) async {
    try {
      final updatedReview = await AppData().review.updateReview(reviewId, rating, comment);
      return updatedReview;
    } catch (e) {
      print('Error updating review $reviewId: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await AppData().review.deleteReview(reviewId);
      print('Review $reviewId deleted successfully.');
    } catch (e) {
      print('Error deleting review $reviewId: $e');
      rethrow;
    }
  }

}