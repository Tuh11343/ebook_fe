import 'package:equatable/equatable.dart';

import '../../models/author.dart';
import '../../models/book.dart';
import '../../models/user.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Book> mainBookList;
  final List<Book> normalBookList;
  final List<Book> premiumBookList;
  final List<Book> topRatingBookList;

  /*----------- Author -------------*/
  final List<Author> authorList;

  /*----------- Login -------------*/
  final bool isLoggedIn;
  final User? currentUser;
  final String? signedUrl;

  const HomeLoaded({
    required this.mainBookList,
    required this.normalBookList,
    required this.premiumBookList,
    required this.topRatingBookList,
    required this.isLoggedIn, // Thêm vào constructor
    required this.authorList,
    this.currentUser,
    this.signedUrl,
  });

  // Thêm copyWith để dễ dàng tạo bản sao với các thay đổi
  HomeLoaded copyWith({
    List<Book>? mainBookList,
    List<Book>? normalBookList,
    List<Book>? premiumBookList,
    List<Book>? topRatingBookList,
    List<Author>? authorList,
    bool? isLoggedIn,
    User? currentUser,
    String? signedUrl,
  }) {
    return HomeLoaded(
      mainBookList: mainBookList ?? this.mainBookList,
      normalBookList: normalBookList ?? this.normalBookList,
      premiumBookList: premiumBookList ?? this.premiumBookList,
      topRatingBookList: topRatingBookList ?? this.topRatingBookList,
      authorList: authorList ?? this.authorList,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      currentUser: currentUser??this.currentUser,
      signedUrl: signedUrl??this.signedUrl
    );
  }

  @override
  List<Object> get props => [
    mainBookList,
    normalBookList,
    premiumBookList,
    topRatingBookList,
    authorList,
    isLoggedIn,
    currentUser ?? Object(),
    signedUrl??Object(),
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}
