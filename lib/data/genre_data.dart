import '../constants/api_mapping.dart';
import 'dio_base.dart';

class GenreData extends DioBase {

  Future<dynamic> getAllGenres({int? limit, int? offset}) async {
    try {
      final response = await super.dio.get(
        APIMapping.findAllGenre, // Đảm bảo APIMapping có endpoint này
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
    } catch (e) {
      print('Unexpected error in getAllGenres: $e');
      rethrow;
    }
  }

  Future<dynamic> getGenresByBookID(String bookID, {int? limit, int? offset}) async {
    try {
      final response = await super.dio.get(
        APIMapping.findGenresByBookId,
        queryParameters: {
          'bookId': bookID,
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
    }catch (e) {
      print('Unexpected error in getGenresByBookID: $e');
      rethrow;
    }
  }
}