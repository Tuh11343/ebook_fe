import 'package:dio/dio.dart';
import 'package:ebook_tuh/constants/app_secure_storage.dart';
import '../constants/api_mapping.dart';
import 'dio_base.dart';

class BookData extends DioBase {
  Future<dynamic> getAllBooks(int? limit, int? offset) async {
    try {
      final response = await super.dio.get(
        APIMapping.findAllBook,
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during getAllBooks: $ex');
      rethrow;
    }
  }

  Future<dynamic> getBooksByGenre(
      String genreId, int? limit, int? offset) async {
    try {
      final response =
          await super.dio.get(APIMapping.findBooksByGenre, queryParameters: {
        'genreId': genreId,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      });

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during getBooksByGenre: $ex');
      rethrow;
    }
  }

  Future<dynamic> getTopRatingBooks(int? limit) async {
    try {
      final response = await super.dio.get(
        APIMapping.findTopRatingBooks,
        queryParameters: {
          if (limit != null) 'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during getTopRatingBooks: $ex');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkBookAccess(String bookId) async {
    try {
      String? token = await AppStorage.getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.get(
            APIMapping.checkBookAccess,
            queryParameters: {
              'bookId': bookId,
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ),
          );

      if (response.statusCode == 200) {
        return response.data['contents'] as Map<String, dynamic>;
      } else {
        String errorMessage =
            'Failed to check book access: ${response.statusCode}';
        if (response.data != null && response.data['message'] != null) {
          errorMessage += ' - ${response.data['message']}';
        }
        throw Exception(errorMessage);
      }
    } catch (ex) {
      print('An unexpected error occurred during checkBookAccess: $ex');
      rethrow;
    }
  }

  Future<dynamic> getPremiumBooks(int? limit, int? offset) async {
    try {
      final response = await super.dio.get(
        APIMapping.findPremiumBooks,
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during getPremiumBooks: $ex');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleFavoriteBook(String bookId) async {
    try {
      String? token = await AppStorage.getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.post(
            APIMapping.toggleFavoriteBooks,
            data: {'bookId': bookId},
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ),
          );

      if (response.statusCode == 200) {
        return response.data['contents'] as Map<String, dynamic>;
      } else {
        throw response.data['status']['code'];
      }
    } catch (ex) {
      print('An unexpected error occurred during toggleFavoriteBook: $ex');
      rethrow;
    }
  }

  Future<bool> isFavorite(String bookId) async {
    try {
      String? token = await AppStorage.getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.get(
            APIMapping.isFavorite,
            queryParameters: {'bookId': bookId},
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            ),
          );

      if (response.statusCode == 200) {
        return response.data['contents'] as bool;
      } else {
        throw response.data['status']['code'];
      }
    } catch (ex) {
      print('An unexpected error occurred during isFavorite: $ex');
      rethrow;
    }
  }

  Future<dynamic> searchBooks({
    String? searchText,
    String? genreId,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await super.dio.get(
        APIMapping.searchBooks,
        queryParameters: {
          if (searchText != null) 'searchText': searchText,
          if (genreId != null) 'genreId': genreId,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during searchBooks: $ex');
      rethrow;
    }
  }

  Future<dynamic> getFavoriteBooks({
    int? limit,
    int? offset,
  }) async {
    try {
      String? token = await AppStorage.getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.get(
            APIMapping.favoriteBooks,
            queryParameters: {
              if (limit != null) 'limit': limit,
              if (offset != null) 'offset': offset,
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
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during getFavoriteBooks: $ex');
      rethrow;
    }
  }

  Future<dynamic> getPurchaseBooks({
    int? limit,
    int? offset,
  }) async {
    try {
      String? token = await AppStorage.getUserToken();

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.get(
            APIMapping.purchaseBooks,
            queryParameters: {
              if (limit != null) 'limit': limit,
              if (offset != null) 'offset': offset,
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
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during getPurchaseBooks: $ex');
      rethrow;
    }
  }

  Future<dynamic> getBooksByAuthor(
      String authorId, int? limit, int? offset) async {
    try {
      final response =
          await super.dio.get(APIMapping.findBooksByAuthor, queryParameters: {
        'authorId': authorId,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      });

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during getBooksByAuthor: $ex');
      rethrow;
    }
  }
}
