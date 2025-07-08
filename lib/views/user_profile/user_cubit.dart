import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:ebook_tuh/controllers/app_controller.dart';
import 'package:ebook_tuh/data/dio_base.dart';
import 'package:ebook_tuh/views/user_profile/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  Future<void> loadUser() async {
    if (state is UserLoading) return; // Tránh tải lại nếu đang tải

    emit(UserLoading());
    try {
      User? user = await AppStorage.getUser();
      if (user == null) {
        emit(const UserError('Không có người dùng'));
        return;
      }

      String? avatarSignedUrl = await AppControllers().auth.getAvatarUrl();

      emit(UserLoaded(user: user, signedUrl: avatarSignedUrl));
    } catch (e) {
      emit(UserError('Failed to load user: $e'));
      // In lỗi ra console để debug
      print('Error loading user from SharedPreferences: $e');
    }
  }

  // Xóa thông tin người dùng (cho hành động đăng xuất)
  Future<void> logOut() async {
    emit(UserLoading());
    try {
      await AppControllers().auth.signOut();
      emit(UserSigningOut());
    } catch (e) {
      emit(UserError('Đăng xuất thất bại: $e'));
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    File? avatarFile,
  }) async {
    try {
      if (avatarFile != null || name != null || phone != null) {
        emit(UserLoading());

        String? avatarUrl;
        if (avatarFile != null) {
          // Lấy thông tin cần thiết cho Signed URL
          final String fileExtension =
              avatarFile.path.split('.').last.toLowerCase();
          final String mimeType;
          switch (fileExtension) {
            case 'jpg':
              mimeType = 'image/jpg';
              break;
            case 'jpeg':
              mimeType = 'image/jpeg';
              break;
            case 'png':
              mimeType = 'image/png';
              break;
            case 'webp':
              mimeType = 'image/webp';
              break;
            default:
              mimeType = 'application/octet-stream';
          }

          final String originalFileName = avatarFile.path.split('/').last;

          print(
              'CUBIT: Requesting signed URL for $originalFileName with type $mimeType');
          final signedUrlResponse =
              await AppControllers().auth.requestAvatarUploadUrl(
                    fileName: originalFileName,
                    contentType: mimeType,
                  );
          final String uploadUrl = signedUrlResponse['uploadUrl'];
          avatarUrl =
              signedUrlResponse['imagePath']; // URL để lưu vào DB/hiển thị

          print('CUBIT: Received uploadUrl: $uploadUrl');
          print('CUBIT: Received fileUrlToSave: $avatarUrl');

          // Upload file trực tiếp lên GCS bằng Signed URL
          print('CUBIT: Uploading file directly to GCS...');
          await DioBase().dio.put(
                uploadUrl,
                data: avatarFile.openRead(), // Gửi stream của file
                options: Options(
                  headers: {
                    Headers.contentLengthHeader: await avatarFile.length(),
                    // Bắt buộc
                    Headers.contentTypeHeader: mimeType,
                    // Bắt buộc và khớp với Signed URL
                  },
                ),
              );
          print('CUBIT: File uploaded successfully to GCS.');
          // Xóa file nén tạm thời sau khi upload xong để giải phóng bộ nhớ
          await avatarFile.delete().catchError(
              (e) => print('Failed to delete temp compressed file: $e'));
        }

        final updatedUser = await AppControllers().auth.updateUserProfileAvatar(
              avatarUrl: avatarUrl,
              phone: phone,
              name: name,
            );

        print('CUBIT: Cập nhật User thành công');

        String? avatarSignedUrl = await AppControllers().auth.getAvatarUrl();
        print('CUBIT: Avatar Signed Url:$avatarSignedUrl');

        emit(UserLoaded(user: updatedUser, signedUrl: avatarSignedUrl));
      }
    } catch (e) {
      // Bắt các loại lỗi không xác định khác
      emit(UserError('Có lỗi không xác định khi cập nhật profile.'));
      print('CUBIT: Unexpected error in updateUserProfile: $e');
    }
  }
}
