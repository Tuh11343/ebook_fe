import 'package:http/http.dart';

class APIMapping {
  APIMapping._();

  static const String hostName = 'http://192.168.1.194:5000';
  // static const String hostName='https://ebooktuh.com';
  static const String createAccount = '/api/v1/account';

  /*---------------- Auth -------------------*/
  static const String login='/api/v1/auth/login';
  static const String register='/api/v1/auth/register';
  static const String googleSignIn='/api/v1/auth/googleSignIn';
  static const String getAvatarUrl = '/api/v1/auth/avatarUrl';
  static const String requestAvatarUpload = '/api/v1/auth/requestAvatarUpload';
  static const String updateProfile='/api/v1/auth/updateProfile';

  /*---------------- Author -------------------*/
  static const String findAllAuthor = '/api/v1/authors';
  static const String findAuthorByBook = '/api/v1/authors/authorBookId';
  static const String findAuthorsByBook = '/api/v1/authors/authorsBookId';
  static const String findAuthorById = '/api/v1/authors/id';

  /*---------------- Book -------------------*/
  static const String findAllBook = '/api/v1/books';
  static const String findBooksByGenre = '/api/v1/books/genre';
  static const String findBooksByAuthor = '/api/v1/books/author';
  static const String findTopRatingBooks = '/api/v1/books/topRating';
  static const String findPremiumBooks = '/api/v1/books/premium';
  static const String toggleFavoriteBooks = '/api/v1/books/toggleFavoriteBook';
  static const String checkBookAccess= '/api/v1/books/checkBookAccess';
  static const String isFavorite= '/api/v1/books/isFavorite';
  static const String searchBooks='/api/v1/books/searchBooks';
  static const String favoriteBooks='/api/v1/books/favorite';
  static const String purchaseBooks='/api/v1/books/purchase';

  /*---------------- Payment -------------------*/
  static const String createPremiumPaymentIntent = '/api/v1/payment/create-premium-payment-intent';
  static const String buyBook='api/v1/payment/buyBook';

  /*---------------- Subscription -------------------*/
  static const String getActiveSubscription='/api/v1/userSubscription/active';

  /*---------------- Review -------------------*/
  static const String findReviewsByBookId='/api/v1/review/bookReviews';
  static const String createReviewByBookId = '/api/v1/review/create';
  static const String updateReviewByBookId = '/api/v1/review/update';
  static const String deleteReviewByBookId = '/api/v1/review/delete';

  /*---------------- Genre -------------------*/
  static const String findAllGenre='/api/v1/genres';
  static const String findGenresByBookId='/api/v1/genres/bookId';

  /*---------------- ReadingProgress -------------------*/
  static const String addBookmark='/api/v1/readingProgress';
  static const String deleteBookmark='/api/v1/readingProgress';
  static const String fetchUserBookBookmark='/api/v1/readingProgress/book';

  /*---------------- Premium Plan -------------------*/
  static const String findAllPremiumPlans='/api/v1/premiumPlan';


  static bool requiresAuth(String path) {
    const Set<String> publicEndpoints = {
      // Thêm các endpoint công khai khác vào đây

      login,
      register,
      googleSignIn,

      /*---------------- Book -------------------*/
      findAllBook,
      findBooksByGenre,
      findBooksByAuthor,
      findTopRatingBooks,
      findPremiumBooks,
      searchBooks,

      /*---------------- Author -------------------*/
      findAllAuthor,
      findAuthorByBook,
      findAuthorsByBook,
      findAuthorById,

      /*---------------- Review -------------------*/
      findReviewsByBookId,

      /*---------------- Genre -------------------*/
      findGenresByBookId,
      findAllGenre,

      /*---------------- Premium Plan -------------------*/
      findAllPremiumPlans,

    };
    return !publicEndpoints.contains(path);
  }
}
