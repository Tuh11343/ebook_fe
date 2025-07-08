import '../data/app_data.dart';
import '../models/genre.dart';

class GenreController {

  Future<List<Genre>> fetchAllGenres({int? limit, int? offset}) async {
    try {
      final result = await AppData().genre.getAllGenres(limit: limit, offset: offset);
      return List<Genre>.from(result.map((x) => Genre.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching all genres: $e');
      rethrow;
    }
  }

  Future<List<Genre>> fetchGenresByBookID(String bookID, {int? limit, int? offset}) async {
    try {
      final result = await AppData().genre.getGenresByBookID(bookID, limit: limit, offset: offset);
      return List<Genre>.from(result.map((x) => Genre.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching genres by book ID $bookID: $e');
      rethrow;
    }
  }


}