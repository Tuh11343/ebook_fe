
import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:ebook_tuh/models/author.dart';
import 'package:ebook_tuh/models/review.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/dummy.dart';
import '../../models/book.dart';
import '../../models/user.dart';
import 'book_detail_event.dart';
import 'book_detail_state.dart';

class BookDetailBloc extends Bloc<BookDetailEvent, BookDetailState> {

  // Constructor nhận Book initial và khởi tạo trạng thái
  BookDetailBloc({required Book initialBook}) :
  // Khởi tạo state ban đầu là Loaded, với book được truyền vào, và đang tải dữ liệu liên quan
        super(BookDetailLoaded(book: initialBook, isLoadingRelatedData: true,isFavorite: false,canAccess: false)) {
    on<LoadBookDetailRelatedData>(
        _onLoadingBookData); // Tên event theo yêu cầu của bạn
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CreateReviewEvent>(_onCreateReview);
    on<UpdateReviewEvent>(_onUpdateReview);
    on<DeleteReviewEvent>(_onDeleteReview);

  }

  Future<void> _onLoadingBookData(LoadBookDetailRelatedData event,
      Emitter<BookDetailState> emit) async {
    // Không cần emit BookDetailLoading() toàn màn hình nữa vì đã có BookDetailLoaded với loading cờ
    // Thay vào đó, chúng ta kiểm tra trạng thái hiện tại
    if (state is BookDetailLoaded) {
      final currentLoadedState = state as BookDetailLoaded;
      // Chỉ tải nếu chưa tải xong dữ liệu liên quan
      if (currentLoadedState.isLoadingRelatedData) {
        try {
          await Future.delayed(const Duration(seconds: 2));

          User? user=await AppStorage.getUser();
          bool canAccess=false;
          bool isFavorite=false;
          if(user!=null){
            canAccess=await AppControllers().book.checkBookAccess(currentLoadedState.book.bookId);
            isFavorite=await AppControllers().book.isFavorite(currentLoadedState.book.bookId);
          }

          List<Author> author=await AppControllers().author.fetchAuthorsByBookID(currentLoadedState.book.bookId);
          final Map<String, dynamic> data =
          await AppControllers().review.fetchReviewsAndStatsByBookId(currentLoadedState.book.bookId);
          List<Review> reviews = [];
          if (data.containsKey('reviews') && data['reviews'] is List) {
            reviews = (data['reviews'] as List).cast<Review>();
          }
          final Map<String, dynamic> reviewSummary =
          data.containsKey('reviewSummary') && data['reviewSummary'] is Map<String, dynamic>
              ? data['reviewSummary'] as Map<String, dynamic>
              : <String, dynamic>{'averageRating': 0.0, 'totalReviews': 0};

          double? averageRating = reviewSummary['averageRating'] as double?;
          int? totalReviews = reviewSummary['totalReviews'] as int?;

          emit(currentLoadedState.copyWith(
            genres: dummyGenres,
            authors: author,
            reviews: reviews,
            isLoadingRelatedData: false, // Đã tải xong
            canAccess: canAccess,
            averageRating: averageRating,
            totalReviews: totalReviews,
            isFavorite:isFavorite,
          ));
        } catch (ex, t) {
          print(ex.toString()); // In stack trace để debug
          // Nếu có lỗi khi tải dữ liệu liên quan, chuyển sang trạng thái lỗi
          // hoặc vẫn giữ lại Book object ban đầu và chỉ báo lỗi cho phần liên quan
          emit(BookDetailError(
              message: 'Error loading related data: ${ex.toString()}'));
        }
      }
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event, Emitter<BookDetailState> emit) async {
    if (state is BookDetailLoaded) {
      final currentLoadedState = state as BookDetailLoaded;
      final bool newFavoriteStatus = !currentLoadedState.isFavorite; // Đảo ngược trạng thái hiện tại

      try {
        await AppControllers().book.toggleFavoriteBook(currentLoadedState.book.bookId);
        emit(currentLoadedState.copyWith(isFavorite: newFavoriteStatus));
      } catch (ex) {
        // Nếu có lỗi trong quá trình gọi API, rollback trạng thái và thông báo lỗi
        emit(currentLoadedState.copyWith(isFavorite: !newFavoriteStatus)); // Rollback
        emit(BookDetailError(message: 'Failed to update favorite status: ${ex.toString()}'));
      }
    }else{
      print('Co lỗi xay ra');
    }
  }

  Future<void> _onCreateReview(
      CreateReviewEvent event, Emitter<BookDetailState> emit) async {
    if (state is BookDetailLoaded) {
      final currentLoadedState = state as BookDetailLoaded;
      try {

        emit(BookDetailLoading());

        await AppControllers().review.createReview(
          event.bookId,
          event.rating,
          event.comment,
        );

        final Map<String, dynamic> data =
        await AppControllers().review.fetchReviewsAndStatsByBookId(currentLoadedState.book.bookId);
        List<Review> reviews = [];
        if (data.containsKey('reviews') && data['reviews'] is List) {
          reviews = (data['reviews'] as List).cast<Review>();
        }
        final Map<String, dynamic> reviewSummary =
        data.containsKey('reviewSummary') && data['reviewSummary'] is Map<String, dynamic>
            ? data['reviewSummary'] as Map<String, dynamic>
            : <String, dynamic>{'averageRating': 0.0, 'totalReviews': 0};

        double? averageRating = reviewSummary['averageRating'] as double?;
        int? totalReviews = reviewSummary['totalReviews'] as int?;


        emit(const BookDetailActionSuccess(
            message: 'Đánh giá của bạn đã được gửi thành công!',
            actionType: 'review_created'
        ));



        emit(currentLoadedState.copyWith(
          reviews: reviews,
          averageRating: averageRating,
          totalReviews: totalReviews,
        ));
      } catch (e) {
        emit(BookDetailError(message: 'Failed to create review: ${e.toString()}'));
      }
    } else {
      print('Error: State is not BookDetailLoaded');
    }
  }

  Future<void> _onUpdateReview(
      UpdateReviewEvent event, Emitter<BookDetailState> emit) async {
    if (state is BookDetailLoaded) {
      final currentLoadedState = state as BookDetailLoaded;
      try {

        emit(BookDetailLoading());

        await AppControllers().review.updateReview(
          event.reviewId,
          event.rating,
          event.comment,
        );

        final Map<String, dynamic> data =
        await AppControllers().review.fetchReviewsAndStatsByBookId(currentLoadedState.book.bookId);

        List<Review> reviews = [];
        if (data.containsKey('reviews') && data['reviews'] is List) {
          reviews = (data['reviews'] as List).cast<Review>();
        }
        final Map<String, dynamic> reviewSummary =
        data.containsKey('reviewSummary') && data['reviewSummary'] is Map<String, dynamic>
            ? data['reviewSummary'] as Map<String, dynamic>
            : <String, dynamic>{'averageRating': 0.0, 'totalReviews': 0};

        double? averageRating = reviewSummary['averageRating'] as double?;
        int? totalReviews = reviewSummary['totalReviews'] as int?;

        // 3. Emit trạng thái thành công để hiển thị SnackBar
        emit(const BookDetailActionSuccess(
            message: 'Đánh giá đã được cập nhật thành công!',
            actionType: 'review_updated'));

        // 4. Cập nhật trạng thái với dữ liệu reviews mới
        emit(currentLoadedState.copyWith(
          reviews: reviews,
          averageRating: averageRating,
          totalReviews: totalReviews,
        ));
      } catch (e) {
        // Xử lý lỗi nếu việc cập nhật thất bại
        emit(BookDetailError(message: 'Failed to update review: ${e.toString()}'));
      }
    } else {
      // Xử lý trường hợp trạng thái không phải BookDetailLoaded (hiếm khi xảy ra nhưng tốt để có)
      emit(BookDetailError(message: 'Failed to update review: Invalid state for action.'));
    }
  }

  Future<void> _onDeleteReview(
      DeleteReviewEvent event, Emitter<BookDetailState> emit) async {
    if (state is BookDetailLoaded) {
      final currentLoadedState = state as BookDetailLoaded;
      try {

        emit(BookDetailLoading());

        // 1. Gọi API để xóa review
        await AppControllers().review.deleteReview(event.reviewId);

        // 2. Sau khi xóa thành công, tải lại danh sách reviews và thống kê
        final Map<String, dynamic> data =
        await AppControllers().review.fetchReviewsAndStatsByBookId(currentLoadedState.book.bookId);

        List<Review> reviews = [];
        if (data.containsKey('reviews') && data['reviews'] is List) {
          reviews = (data['reviews'] as List).cast<Review>();
        }
        final Map<String, dynamic> reviewSummary =
        data.containsKey('reviewSummary') && data['reviewSummary'] is Map<String, dynamic>
            ? data['reviewSummary'] as Map<String, dynamic>
            : <String, dynamic>{'averageRating': 0.0, 'totalReviews': 0};

        double? averageRating = reviewSummary['averageRating'] as double?;
        int? totalReviews = reviewSummary['totalReviews'] as int?;

        // 3. Emit trạng thái thành công để hiển thị SnackBar
        emit(const BookDetailActionSuccess(
            message: 'Đánh giá đã được xóa thành công!',
            actionType: 'review_deleted'));

        // 4. Cập nhật trạng thái với dữ liệu reviews mới
        emit(currentLoadedState.copyWith(
          reviews: reviews,
          averageRating: averageRating,
          totalReviews: totalReviews,
        ));
      } catch (e) {
        // Xử lý lỗi nếu việc xóa thất bại
        emit(BookDetailError(message: 'Failed to delete review: ${e.toString()}'));
      }
    } else {
      // Xử lý trường hợp trạng thái không phải BookDetailLoaded
      emit(BookDetailError(message: 'Failed to delete review: Invalid state for action.'));
    }
  }
}
