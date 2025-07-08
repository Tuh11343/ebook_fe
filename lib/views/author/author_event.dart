import 'package:equatable/equatable.dart';

import '../../models/author.dart';

abstract class AuthorEvent extends Equatable {
  const AuthorEvent();

  @override
  List<Object> get props => [];
}

class LoadAuthorRelatedData extends AuthorEvent {
  final Author author;
  const LoadAuthorRelatedData({required this.author});

  @override
  List<Object> get props => [author];
}
