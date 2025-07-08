import 'package:equatable/equatable.dart';

import '../../models/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;
  final String? signedUrl;

  // Use named arguments in the constructor
  const UserLoaded({required this.user, this.signedUrl});

  // Thêm copyWith để dễ dàng tạo bản sao với các thay đổi
  UserLoaded copyWith({
    User? user,
    String? signedUrl,
  }) {
    return UserLoaded(
      user: user ?? this.user,
      signedUrl: signedUrl ?? this.signedUrl,
    );
  }

  @override
  List<Object?> get props => [user, signedUrl];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// Trạng thái mới cho quá trình đăng xuất
class UserSigningOut extends UserState {}