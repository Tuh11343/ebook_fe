import 'package:dio/dio.dart';

import '../constants/api_mapping.dart';
import '../constants/app_secure_storage.dart';
import '../models/reading_progress.dart';
import 'dio_base.dart';

class ReadingProgressData extends DioBase {
  Future<dynamic> addBookmark(
    String bookId, {
    String? chapterTitle,
    int? chapterNumber,
    int? paragraphNumber,
    String? cfi,
    double? audioProgressSeconds,
    bool? completed,
  }) async {
    try {
      String? token = await AppStorage.getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.post(APIMapping.addBookmark,
          data: {
            'bookId': bookId,
            if (chapterTitle != null) 'chapterTitle': chapterTitle,
            if (chapterNumber != null) 'chapterNumber': chapterNumber,
            if (paragraphNumber != null) 'paragraphNumber': paragraphNumber,
            if (cfi != null) 'cfi': cfi,
            if (audioProgressSeconds != null)
              'audioProgressSeconds': audioProgressSeconds,
            if (completed != null) 'completed': completed,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ));

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchUserBookBookmark(
    String bookId, {
    int? limit,
    int? offset,
  }) async {
    try {
      String? token = await AppStorage.getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.get(APIMapping.fetchUserBookBookmark,
          queryParameters: {
            'bookId': bookId,
            if (limit != null) 'limit': limit,
            if (offset != null) 'offset': offset,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ));

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteBookmark(String progressId) async {
    try {
      String? token = await AppStorage.getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.delete(APIMapping.deleteBookmark,
          data: {'progressId': progressId},
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ));

      if (response.statusCode == 200) {
        // Assuming 200 OK for successful deletion
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
