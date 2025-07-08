import 'package:ebook_tuh/controllers/genre_controller.dart';
import 'package:ebook_tuh/controllers/payment_controller.dart';
import 'package:ebook_tuh/controllers/premium_plan_controller.dart';
import 'package:ebook_tuh/controllers/reading_progress_controller.dart';
import 'package:ebook_tuh/controllers/review_controller.dart';
import 'package:ebook_tuh/controllers/subscription_controller.dart';

import 'auth_controller.dart';
import 'author_controller.dart';
import 'book_controller.dart';

class AppControllers {
  static final AppControllers _instance = AppControllers._internal();

  factory AppControllers() {
    return _instance;
  }

  AppControllers._internal() {
    _bookController = BookController();
    _authorController = AuthorController();
    _paymentController = PaymentController();
    _userSubscriptionController = UserSubscriptionController();
    _authController = AuthController();
    _reviewController = ReviewController();
    _genreController = GenreController();
    _readingProgressController = ReadingProgressController();
    _premiumPlanController = PremiumPlanController();
  }

  // Khai báo các controller
  late final BookController _bookController;
  late final AuthorController _authorController;
  late final PaymentController _paymentController;
  late final UserSubscriptionController _userSubscriptionController;
  late final AuthController _authController;
  late final ReviewController _reviewController;
  late final GenreController _genreController;
  late final ReadingProgressController _readingProgressController;
  late final PremiumPlanController _premiumPlanController;

  BookController get book => _bookController;

  AuthorController get author => _authorController;

  PaymentController get payment => _paymentController;

  UserSubscriptionController get userSubscription =>
      _userSubscriptionController;

  AuthController get auth => _authController;

  ReviewController get review => _reviewController;

  GenreController get genre => _genreController;

  ReadingProgressController get readingProgress => _readingProgressController;

  PremiumPlanController get premiumPlan => _premiumPlanController;
}
