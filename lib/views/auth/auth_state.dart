import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, success, failure }

enum AuthActionType {
  none,
  signIn,
  signUp,
  signOut,
  requestPasswordReset,
  resetPassword,
  verifyOtp,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final String? successMessage;
  final AuthActionType actionType;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.actionType = AuthActionType.none,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? successMessage,
    AuthActionType? actionType,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      actionType: actionType ?? this.actionType,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage, actionType];
}