import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../constants/app_secure_storage.dart';
import '../../data/auth_data.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {

  AuthCubit() : super(const AuthState());

  Future<void> checkInitialAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading, actionType: AuthActionType.none));
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(status: AuthStatus.initial));
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      actionType: AuthActionType.signIn,
      errorMessage: null,
      successMessage: null,
    ));
    try {
      // Gọi phương thức loginUser từ AuthController
      final userResponse = await AppControllers().auth.loginUser(email, password);

      emit(state.copyWith(
        status: AuthStatus.success,
        actionType: AuthActionType.signIn,
        successMessage: 'Đăng nhập thành công!',
      ));


    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        actionType: AuthActionType.signIn,
        errorMessage: 'Đã xảy ra lỗi khi đăng nhập: ${e.toString()}',
      ));
    }
  }

  Future<void> signUp(String fullName, String email, String password) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      actionType: AuthActionType.signUp,
      errorMessage: null,
      successMessage: null,
    ));
    try {

      final userResponse = await AppControllers().auth.registerUser(email, password, fullName);

      emit(state.copyWith(
        status: AuthStatus.success,
        actionType: AuthActionType.signUp,
        successMessage: 'Đăng ký thành công!',
      ));

    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        actionType: AuthActionType.signUp,
        errorMessage: 'Đã xảy ra lỗi khi đăng ký: ${e.toString()}',
      ));
    }
  }

  /// Hàm đăng nhập bằng Google.
  Future<void> googleSignIn() async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      actionType: AuthActionType.signIn,
      errorMessage: null,
      successMessage: null,
    ));
    try {

      final appUserContent = await AppControllers().auth.signInWithGoogle();

      emit(state.copyWith(
        status: AuthStatus.success,
        actionType: AuthActionType.signIn,
        successMessage: 'Đăng nhập Google thành công!',
        // Bạn có thể lưu trữ userCredential.user hoặc appUserContent vào AuthState nếu cần
      ));

    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        actionType: AuthActionType.signIn,
        errorMessage: 'Lỗi không xác định khi đăng nhập Google: ${e.toString()}',
      ));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      actionType: AuthActionType.signOut,
      errorMessage: null,
      successMessage: null,
    ));


    try {
      await AppControllers().auth.signOut();

      emit(const AuthState(
        status: AuthStatus.initial,
        actionType: AuthActionType.signOut,
        successMessage: 'Đăng xuất thành công!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        actionType: AuthActionType.signOut,
        errorMessage: 'Đã xảy ra lỗi khi đăng xuất: ${e.toString()}',
      ));
    }
  }

  void clearActionAndMessages() {
    emit(state.copyWith(
        errorMessage: null,
        successMessage: null,
        actionType: AuthActionType.none,
        status: AuthStatus.initial
    ));
  }
}