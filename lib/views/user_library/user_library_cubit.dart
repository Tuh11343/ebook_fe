import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:ebook_tuh/data/dummy.dart';
import 'package:ebook_tuh/views/user_library/user_library_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/book.dart';
import '../../models/user.dart';
import '../../models/user_library.dart';

class UserLibraryCubit extends Cubit<UserLibraryState> {
  UserLibraryCubit() : super(const UserLibraryState());

  /// Tải danh sách sách đã thích và đã mua của người dùng.
  Future<void> loadUserLibraryBooks() async {
    emit(state.copyWith(status: UserLibraryStatus.loading));
    try {
      List<Book> favoriteBooks=[];
      List<Book> purchaseBooks=[];

      User? user=await AppStorage.getUser();
      if(user==null){
        emit(state.copyWith(
          status: UserLibraryStatus.error,
          errorMessage: 'Không có thông tin người dùng',
        ));
        return;
      }

      favoriteBooks=await AppControllers().book.fetchFavoriteBooks();
      purchaseBooks=await AppControllers().book.fetchPurchaseBooks();

      emit(state.copyWith(
        status: UserLibraryStatus.loaded,
        likedBooks: favoriteBooks,
        purchasedBooks: purchaseBooks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserLibraryStatus.error,
        errorMessage: 'Không thể tải thư viện người dùng: $e',
      ));
    }
  }

}