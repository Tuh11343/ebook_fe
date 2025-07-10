import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/app_secure_storage.dart';
import '../data/app_data.dart';
import '../models/user.dart' as user_model;

class AuthController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<user_model.User> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Firebase user is null after sign-in.");
      }

      final backendResponse = await AppData().auth.login(email, password);

      user_model.User userResponse =
          user_model.User.fromJson(backendResponse as Map<String, dynamic>);
      await AppStorage.saveUserAuthentication(userResponse);

      return userResponse;
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }

  Future<user_model.User> registerUser(
      String email, String password, String fullName) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Firebase user is null after registration.");
      }

      final backendResponse =
          await AppData().auth.register(email, password, username: fullName);

      user_model.User userResponse =
          user_model.User.fromJson(backendResponse as Map<String, dynamic>);

      await AppStorage.saveUserAuthentication(userResponse);

      return userResponse;
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }

  Future<user_model.User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("Đăng nhập Google bị hủy.");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception("Không thể lấy Google ID Token hoặc Access Token.");
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Firebase user is null after Google sign-in.");
      }

      final String? firebaseIdToken = await firebaseUser.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception("Không thể lấy Firebase ID Token.");
      }

      final backendResponse =
          await AppData().auth.googleSignIn(firebaseIdToken);

      user_model.User userResponse =
          user_model.User.fromJson(backendResponse as Map<String, dynamic>);
      await AppStorage.saveUserAuthentication(userResponse);

      return userResponse;
    } catch (e) {
      print('Error during Google sign-in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await AppStorage.clearUser();
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy người dùng với email này.';
          break;
        case 'invalid-email':
          errorMessage = 'Địa chỉ email không hợp lệ.';
          break;
        default:
          errorMessage = 'Không thể gửi email đặt lại mật khẩu: ${e.message}';
          break;
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  Future<user_model.User> updateUserProfileAvatar({
    String? avatarUrl,
    String? name,
    String? phone,
  }) async {
    try {
      final backendResponse = await AppData()
          .auth
          .updateProfile(avatarUrl: avatarUrl, name: name, phone: phone);

      user_model.User userResponse = user_model.User.fromJson(backendResponse);
      await AppStorage.saveUserAuthentication(userResponse);

      return userResponse;
    } catch (e) {
      print('Error in AuthController.updateUserProfileAvatar: $e');
      rethrow;
    }
  }

  Future<String?> getAvatarUrl() async {
    try {
      final avatarUrl = await AppData().auth.getMyAvatarUrl();
      return avatarUrl;
    } catch (e) {
      print('Error in AuthController.getAvatarUrl: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestAvatarUploadUrl({
    required String fileName,
    required String contentType,
  }) async {
    try {
      final response = await AppData().auth.requestAvatarUpload(
            fileName: fileName,
            contentType: contentType,
          );
      return response;
    } catch (e) {
      print('Error in AuthController.requestAvatarUploadUrl: $e');
      rethrow;
    }
  }


  Future<String> requestPasswordReset(String email) async {
    try {
      final message = await AppData().auth.requestPasswordReset(email);
      return message;
    } catch (e) {
      print('Lỗi không mong muốn trong AuthController.requestBackendPasswordReset: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.');
    }
  }

  Future<String> resetPassword(String email, String otp, String newPassword) async {
    try {
      final message = await AppData().auth.resetPassword(email, otp, newPassword);
      return message;
    } catch (e) {
      print('Lỗi không mong muốn trong AuthController.performPasswordReset: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.');
    }
  }

  Future<VerifyOtpResult> verifyOtp(String email, String otp) async {
    try {
      final result = await AppData().auth.verifyOtp(email, otp);
      final String message = result['status']['message'] ?? 'Thành công.';
      final bool success = result['contents'] as bool;
      return VerifyOtpResult(success: success, message: message);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.');
    }
  }

}

class VerifyOtpResult {
  final bool success;
  final String message;

  VerifyOtpResult({required this.success, required this.message});

  @override
  String toString() {
    return 'VerifyOtpResult(success: $success, message: $message)';
  }
}
