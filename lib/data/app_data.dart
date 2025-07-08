import 'package:ebook_tuh/data/premium_plan_data.dart';

import 'auth_data.dart';
import 'author_data.dart';
import 'book_data.dart';
import 'genre_data.dart';
import 'payment_data.dart';
import 'reading_progress_data.dart';
import 'review_data.dart';
import 'subscription_data.dart';

class AppData {
  static final AppData _instance = AppData._internal();

  factory AppData() {
    return _instance;
  }

  AppData._internal() {
    _bookData = BookData();
    _authorData = AuthorData();
    _paymentData = PaymentData();
    _userSubscriptionData = SubscriptionData();
    _authData = AuthData();
    _reviewData = ReviewData();
    _genreData = GenreData();
    _readingProgressData = ReadingProgressData();
    _premiumPlanData = PremiumPlanData();
  }

  // Khai báo các Data
  late final BookData _bookData;
  late final AuthorData _authorData;
  late final PaymentData _paymentData;
  late final SubscriptionData _userSubscriptionData;
  late final AuthData _authData;
  late final ReviewData _reviewData;
  late final GenreData _genreData;
  late final ReadingProgressData _readingProgressData;
  late final PremiumPlanData _premiumPlanData;

  BookData get book => _bookData;

  AuthorData get author => _authorData;

  PaymentData get payment => _paymentData;

  SubscriptionData get userSubscription => _userSubscriptionData;

  AuthData get auth => _authData;

  ReviewData get review => _reviewData;

  GenreData get genre => _genreData;

  ReadingProgressData get readingProgress => _readingProgressData;

  PremiumPlanData get premiumPlan => _premiumPlanData;
}
