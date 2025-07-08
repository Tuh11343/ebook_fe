import '../data/app_data.dart';
import '../models/author.dart';

class AuthorController {
  Future<List<Author>> fetchAllAuthors({int? limit, int? offset}) async {
    try {
      final result = await AppData().author.getAllAuthors(limit, offset);
      return List<Author>.from(
          result.map((x) => Author.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching all authors: $e');
      rethrow;
    }
  }

  Future<Author?> fetchAuthorByID(String authorID,
      {int? limit, int? offset}) async {
    try {
      final result =
          await AppData().author.getAuthorByID(authorID, limit, offset);
      if (result != null && result is Map<String, dynamic>) {
        return Author.fromJson(result);
      }
      return null;
    } catch (e) {
      print('Error fetching author by ID $authorID: $e');
      rethrow;
    }
  }

  Future<List<Author>> fetchAuthorsByBookID(String bookID,
      {int? limit, int? offset}) async {
    try {
      final result =
          await AppData().author.getAuthorsByBookID(bookID, limit, offset);
      return List<Author>.from(
          result.map((x) => Author.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching authors by book ID $bookID: $e');
      rethrow;
    }
  }

  Future<Author?> fetchAuthorByBookID(String bookID,
      {int? limit, int? offset}) async {
    try {
      final result =
          await AppData().author.getAuthorByBookID(bookID, limit, offset);
      if (result != null && result is Map<String, dynamic>) {
        return Author.fromJson(result);
      }
      return null;
    } catch (e) {
      print('Error fetching single author by book ID $bookID: $e');
      rethrow;
    }
  }
}
