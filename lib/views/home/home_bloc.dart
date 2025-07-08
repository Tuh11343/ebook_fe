import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:ebook_tuh/data/dummy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/user.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {


  HomeBloc() : super(HomeInitial()) {
    on<FirstInitEvent>(_firstInit);
    on<UpdateUserEvent>(_updateUser);
  }

  void _firstInit(FirstInitEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      List<Book> mainBookList =
          await AppControllers().book.fetchAllBooks(limit: 10, offset: 0);
      List<Book> topRatingBookList =
          await AppControllers().book.fetchTopRatingBooks(limit: 10);
      List<Book> normalBookList =
          await AppControllers().book.fetchAllBooks();
      List<Book> premiumBookList =
          await AppControllers().book.fetchPremiumBooks();
      List<Author> authorList=await AppControllers().author.fetchAllAuthors(limit: 7,offset: 0);

      // Các dòng sử dụng hàm này:
      final List<Book> finalMainBookList =
      _isListEmptyOrNull(mainBookList) ? dummyBooks : mainBookList;
      final List<Book> finalTopRatingBookList =
      _isListEmptyOrNull(topRatingBookList) ? dummyBooks : topRatingBookList;
      final List<Book> finalNormalBookList =
      _isListEmptyOrNull(normalBookList) ? dummyBooks : normalBookList;
      final List<Book> finalPremiumBookList =
      _isListEmptyOrNull(premiumBookList) ? dummyBooks : premiumBookList;
      final List<Author> finalAuthorList =
      _isListEmptyOrNull(authorList) ? dummyAuthors : authorList;

      User? tempUser;
      String? signedUrl;
      bool isLoggedIn=await AppStorage.isAuthenticatedUser();
      if(isLoggedIn){
        tempUser=await AppStorage.getUser();
        signedUrl=await AppControllers().auth.getAvatarUrl();
      }

      emit(HomeLoaded(
        mainBookList: finalMainBookList,
        normalBookList: finalNormalBookList,
        premiumBookList: finalPremiumBookList,
        topRatingBookList: finalTopRatingBookList,
        isLoggedIn: isLoggedIn,
        authorList: finalAuthorList,
        currentUser: tempUser,
        signedUrl: signedUrl,
      ));
    } catch (ex, t) {
      print(t);
      emit(HomeError(ex.toString()));
    }
  }

  void _updateUser(UpdateUserEvent event, Emitter<HomeState> emit) async{
    try{
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;

        User? user=await AppStorage.getUser();
        if(user!=null){
          String? signedUrl=await AppControllers().auth.getAvatarUrl();
          emit(currentState.copyWith(
            currentUser: user,
            isLoggedIn: true,
            signedUrl: signedUrl
          ));
        }else{
          emit(currentState.copyWith(
            currentUser: null,
            isLoggedIn: false,
            signedUrl: null,
          ));
        }
      }
    }catch(ex,t){
      emit(HomeError(ex.toString()));
    }
  }

  bool _isListEmptyOrNull(List<dynamic>? list) {
    return list == null || list.isEmpty;
  }
}
