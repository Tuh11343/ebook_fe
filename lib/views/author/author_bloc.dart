import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import 'author_event.dart';
import 'author_state.dart';

class AuthorBloc extends Bloc<AuthorEvent, AuthorState> {
  AuthorBloc({required Author initialAuthor}) :
        super(AuthorLoaded(author: initialAuthor, isLoadingRelatedData: true)){
    on<LoadAuthorRelatedData>(_onLoadAuthorRelatedData);
  }

  Future<void> _onLoadAuthorRelatedData(LoadAuthorRelatedData event,
      Emitter<AuthorState> emit) async {
    if (state is AuthorLoaded) {
      final currentLoadedState = state as AuthorLoaded;
      if (currentLoadedState.isLoadingRelatedData) {
        try {
          List<Book> bookList=await AppControllers().book.fetchBooksByAuthor(currentLoadedState.author.authorId);

          emit(currentLoadedState.copyWith(
            books: bookList,
            isLoadingRelatedData:false  // Đã tải xong
          ));
        } catch (ex, t) {
          print(t);
          emit(AuthorError(
            message: 'Đã xảy ra lỗi khi tải danh sách sách: ${ex.toString()}',
          ));
        }
      }
    }
  }
}