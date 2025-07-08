import 'package:equatable/equatable.dart';

import '../../models/author.dart';
import '../../models/book.dart';

abstract class AuthorState extends Equatable {
  const AuthorState();

  @override
  List<Object> get props => [];
}

class AuthorInitial extends AuthorState {}

class AuthorLoading extends AuthorState {}

class AuthorLoaded extends AuthorState {
  final Author author;
  final List<Book> books;
  final bool isLoadingRelatedData;

  const AuthorLoaded({
    required this.author,
    this.books = const [],
    this.isLoadingRelatedData = false,
  });

  AuthorLoaded copyWith({
    Author? author,
    List<Book>? books,
    bool? isLoadingRelatedData,
  }) {
    return AuthorLoaded(
      author: author ?? this.author,
      books: books ?? this.books,
      isLoadingRelatedData: isLoadingRelatedData ?? this.isLoadingRelatedData,
    );
  }

  @override
  List<Object> get props => [author, books, isLoadingRelatedData];
}

class AuthorError extends AuthorState {
  final String message;

  const AuthorError({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
