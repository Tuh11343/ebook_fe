import '../data/app_data.dart';
import '../models/book.dart';
import '../models/user_library.dart';

class BookController {

  Future<List<Book>> fetchAllBooks({int? limit, int? offset}) async {
    try {
      final result = await AppData().book.getAllBooks(limit, offset);
      return List<Book>.from(
          result.map((x) => Book.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching all books: $e');
      rethrow;
    }
  }

  Future<List<Book>> fetchTopRatingBooks({int? limit}) async {
    try {
      final result = await AppData().book.getTopRatingBooks(limit);
      return List<Book>.from(
          result.map((x) => Book.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching all books: $e');
      rethrow;
    }
  }

  Future<List<Book>> fetchPremiumBooks({int? limit, int? offset}) async {
    try {
      final result = await AppData().book.getPremiumBooks(limit, offset);
      return List<Book>.from(
          result.map((x) => Book.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching all books: $e');
      rethrow;
    }
  }

  Future<List<Book>> fetchBooksByGenre(String genreId,
      {int? limit, int? offset}) async {
    try {
      final result = await AppData().book.getBooksByGenre(genreId, limit, offset);
      return List<Book>.from(
          result.map((x) => Book.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching books by genre $genreId: $e');
      rethrow;
    }
  }

  Future<List<Book>> fetchBooksByAuthor(String authorId,
      {int? limit, int? offset}) async {
    try {
      final result = await AppData().book.getBooksByAuthor(authorId, limit, offset);
      return List<Book>.from(
          result.map((x) => Book.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching books by genre $authorId: $e');
      rethrow;
    }
  }

  Future<List<Book>> fetchFavoriteBooks({int? limit, int? offset}) async {
    try {
      final result =
          await AppData().book.getFavoriteBooks(limit: limit, offset: offset);
      return List<Book>.from(
          result.map((x) => Book.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching favorite books');
      rethrow;
    }
  }

  Future<List<Book>> fetchPurchaseBooks({int? limit, int? offset}) async {
    try {
      final result =
          await AppData().book.getPurchaseBooks(limit: limit, offset: offset);
      return List<Book>.from(
          result.map((x) => Book.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error fetching purchase books');
      rethrow;
    }
  }

  Future<bool> checkBookAccess(String bookId) async {
    try {
      final Map<String, dynamic> result =
          await AppData().book.checkBookAccess(bookId);

      if (result.containsKey('hasAccess') && result['hasAccess'] is bool) {
        return result['hasAccess'] as bool;
      } else {
        throw Exception(
            'Invalid response format for book access check: "hasAccess" field missing or not a boolean.');
      }
    } catch (e) {
      print('Error checking book access for bookId $bookId: $e');
      rethrow;
    }
  }

  Future<UserLibrary> toggleFavoriteBook(String bookId) async {
    try {
      final result = await AppData().book.toggleFavoriteBook(bookId);
      return UserLibrary.fromJson(result);
    } catch (e) {
      print('Error toggling favorite status for bookId $bookId: $e');
      rethrow;
    }
  }

  Future<bool> isFavorite(String bookId) async {
    try {
      final result = await AppData().book.isFavorite(bookId);
      return result;
    } catch (e) {
      print('Error toggling favorite status for bookId $bookId: $e');
      rethrow;
    }
  }

  Future<List<Book>> searchBooks({
    String? searchText,
    String? genreId,
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await AppData().book.searchBooks(
        searchText: searchText,
        genreId: genreId,
        limit: limit,
        offset: offset,
      );

      return List<Book>.from(
          result.map((x) => Book.fromJson(x as Map<String, dynamic>)));
    } catch (e) {
      print('Error searching books: $e');
      rethrow;
    }
  }
}
