import 'package:dio/dio.dart';

import '../constants/api_mapping.dart';
import '../constants/app_secure_storage.dart';
import '../models/review.dart';
import 'dio_base.dart';

class ReviewData extends DioBase {
  Future<Map<String, dynamic>> getReviewsAndStatsByBookId(String bookId) async {
    try {
      final response =
          await super.dio.get(APIMapping.findReviewsByBookId, queryParameters: {
        'bookId': bookId,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] != null &&
            responseData['status']['code'] == 200) {
          final List<Review> reviews = [];
          Map<String, dynamic> reviewSummary = {
            'averageRating': 0.0,
            'totalReviews': 0,
          };

          if (responseData.containsKey('contents') &&
              responseData['contents'] is List) {
            final List<dynamic> reviewsJson = responseData['contents'];
            reviews.addAll(reviewsJson
                .map((json) => Review.fromJson(json as Map<String, dynamic>))
                .toList());
          }

          if (responseData.containsKey('averageRating') &&
              responseData['averageRating'] is num) {
            reviewSummary['averageRating'] =
                (responseData['averageRating'] as num).toDouble();
          }
          if (responseData.containsKey('totalReviews') &&
              responseData['totalReviews'] is int) {
            reviewSummary['totalReviews'] = responseData['totalReviews'] as int;
          }
          if (responseData.containsKey('reviewSummary') &&
              responseData['reviewSummary'] is Map<String, dynamic>) {
            reviewSummary
                .addAll(responseData['reviewSummary'] as Map<String, dynamic>);
          }

          return {
            'reviews': reviews,
            'reviewSummary': reviewSummary,
          };
        } else {
          throw Exception(responseData['status']['message'] ??
              'API Error fetching reviews and stats.');
        }
      } else {
        throw Exception(
            'HTTP Error ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      print('Unexpected error fetching reviews and stats: $e');
      rethrow;
    }
  }

  Future<Review> createReview(
      String bookId, int rating, String? comment) async {
    try {
      String? token = await AppStorage.getUserToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.post(
            APIMapping.createReviewByBookId,
            data: {
              'bookId': bookId,
              'rating': rating,
              'comment': comment,
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ),
          );

      if (response.statusCode == 201) {
        // Mã 201 Created
        if (response.data['status']['code'] == 201) {
          return Review.fromJson(
              response.data['contents'] as Map<String, dynamic>);
        } else {
          throw Exception(response.data['status']['message'] ??
              'API Error creating review.');
        }
      } else {
        throw response.data['status']['code'];
      }
    } catch (e) {
      print('Unexpected error creating review: $e');
      rethrow;
    }
  }

  Future<Review> updateReview(
      String reviewId, int? rating, String? comment) async {
    try {
      String? token = await AppStorage.getUserToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.post(
            APIMapping.updateReviewByBookId,
            data: {
              'id': reviewId,
              if (rating != null) 'rating': rating,
              if (comment != null) 'comment': comment,
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ),
          );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return Review.fromJson(
              response.data['contents'] as Map<String, dynamic>);
        } else {
          throw Exception(response.data['status']['message'] ??
              'API Error updating review.');
        }
      } else {
        throw response.data['status']['code'];
      }
    } catch (e) {
      print('Unexpected error updating review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      String? token = await AppStorage.getUserToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.delete(
            APIMapping.deleteReviewByBookId,
            data: {'id': reviewId},
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ),
          );

      if (response.statusCode == 204) {
        return;
      } else {
        throw response.data['status']['code'];
      }
    } catch (e) {
      print('Unexpected error deleting review: $e');
      rethrow;
    }
  }
}
