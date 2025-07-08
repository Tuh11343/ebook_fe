// Enum cho trạng thái tải thư viện
import 'package:equatable/equatable.dart';

import '../../models/book.dart';

// Enum cho trạng thái tải thư viện
enum UserLibraryStatus { initial, loading, loaded, error } // Đã đổi tên

// Trạng thái của UserLibraryCubit
class UserLibraryState extends Equatable { // Đã đổi tên
  final UserLibraryStatus status; // Đã đổi tên
  final List<Book> favoriteBooks;
  final List<Book> purchasedBooks;
  final String? errorMessage;

  const UserLibraryState({ // Đã đổi tên
    this.status = UserLibraryStatus.initial, // Đã đổi tên
    this.favoriteBooks = const [],
    this.purchasedBooks = const [],
    this.errorMessage,
  });

  UserLibraryState copyWith({ // Đã đổi tên
    UserLibraryStatus? status, // Đã đổi tên
    List<Book>? likedBooks,
    List<Book>? purchasedBooks,
    String? errorMessage,
  }) {
    return UserLibraryState( // Đã đổi tên
      status: status ?? this.status,
      favoriteBooks: likedBooks ?? this.favoriteBooks,
      purchasedBooks: purchasedBooks ?? this.purchasedBooks,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    favoriteBooks,
    purchasedBooks,
    errorMessage,
  ];
}