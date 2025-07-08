import '../constants/api_mapping.dart';
import 'dio_base.dart';

class AuthorData extends DioBase {
  Future<dynamic> getAllAuthors(int? limit, int? offset) async {
    try {
      final response = await super.dio.get(
            APIMapping.findAllAuthor,
          );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    } catch (ex) {
      print('An unexpected error occurred during getAllAuthors: $ex');
      rethrow;
    }
  }

  Future<dynamic> getAuthorByBookID(
      String bookID, int? limit, int? offset) async {
    try {
      final response =
          await super.dio.get(APIMapping.findAuthorById, queryParameters: {
        'id': bookID,
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
      print('An unexpected error occurred during getAllAuthors: $ex');
      rethrow;
    }
  }

  Future<dynamic> getAuthorsByBookID(
      String bookID, int? limit, int? offset) async {
    try {
      final response =
          await super.dio.get(APIMapping.findAuthorsByBook, queryParameters: {
        'bookId': bookID,
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
      print('An unexpected error occurred during getAllAuthors: $ex');
      rethrow;
    }
  }

  Future<dynamic> getAuthorByID(String bookID, int? limit, int? offset) async {
    try {
      final response =
          await super.dio.get(APIMapping.findAuthorById, queryParameters: {
        'id': bookID,
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
      print('An unexpected error occurred during getAllAuthors: $ex');
      rethrow;
    }
  }
}
