import 'package:dio/dio.dart';

import '../constants/api_mapping.dart';
import '../constants/app_secure_storage.dart';
import 'dio_base.dart';

class AuthData extends DioBase {

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await super.dio.post(
        APIMapping.login,
        data: {
          'identifier': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    }catch (e) {
      print('An unexpected error occurred during login: $e');
      rethrow;
    }
  }

  Future<dynamic> register(String email, String password, {String? username}) async {
    try {
      final response = await super.dio.post(
        APIMapping.register,
        data: {
          'email': email,
          'password': password,
          if (username != null) 'name': username,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    }catch (e) {
      print('An unexpected error occurred during registration: $e');
      rethrow;
    }
  }

  Future<dynamic> googleSignIn(String idToken) async {
    try {
      final response = await super.dio.post(
        APIMapping.googleSignIn,
        data: {
          'firebaseIdToken': idToken,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status']['code'] == 200) {
          return response.data['contents'];
        } else {
          throw response.data['status']['code'];
        }
      }
    }catch (e) {
      print('An unexpected error occurred during Google sign-in: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestAvatarUpload({
    required String fileName,
    required String contentType,
  }) async {
    try {

      String? token = await AppStorage.getUserToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await super.dio.post(
        APIMapping.requestAvatarUpload,
        data: {
          'fileName': fileName,
          'contentType': contentType,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data['status']['code'] == 200) {
        return response.data['contents'] as Map<String, dynamic>;
      } else {
        throw response.data['status']['code'];
      }
    } catch (e) {
      print('An unexpected error occurred during getSignedUploadUrl: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      String? token = await AppStorage.getUserToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

      if (data.isEmpty) {
        throw Exception("No data provided to update profile.");
      }

      final response = await dio.post(
        APIMapping.updateProfile,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status']['code'] == 200) {
        return response.data['contents'] as Map<String, dynamic>;
      } else {
        throw response.data['status']['code'];
      }
    } catch (e) {
      print('An unexpected error occurred during updateProfile: $e');
      rethrow;
    }
  }

  Future<String?> getMyAvatarUrl() async {
    try {
      String? token = await AppStorage.getUserToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final response = await dio.get(
        APIMapping.getAvatarUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status']['code'] == 200) {
        return response.data['contents']['avatarUrl'] as String?;
      } else {
        throw response.data['status']['code'];
      }
    } catch (e) {
      print('An unexpected error occurred during getMyAvatarUrl: $e');
      rethrow;
    }
  }




}