import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/user_role.dart'; // Đảm bảo đường dẫn này đúng

class AppStorage {
  AppStorage._(); // Singleton

  static const _storage = FlutterSecureStorage();
  static late SharedPreferences _sharedPreferences;

  // Khởi tạo SharedPreferences
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // Lưu thông tin người dùng sau khi đăng nhập
  static Future<void> saveUserAuthentication(User userModel) async {
    try {
      if (userModel.token == null) {
        throw Exception('Token is null, cannot save user authentication.');
      }
      if (userModel.userId.isEmpty) {
        throw Exception('UserId is empty, cannot save user authentication.');
      }

      // Gộp các thao tác ghi vào một lần
      await Future.wait([
        _storage.write(key: 'token', value: userModel.token!),
        _storage.write(key: 'userId', value: userModel.userId), // userId đã là String
        _storage.write(key: 'userName', value: userModel.name), // name là non-nullable
        _storage.write(key: 'userRole', value: userModel.role.toString()), // Chuyển enum sang String
        _storage.write(key: 'userEmail', value: userModel.email ?? ''), // Xử lý nullable email
        _storage.write(key: 'phoneNumber', value: userModel.phone ?? ''), // Xử lý nullable phone
        _storage.write(key: 'avatarUrl', value: userModel.avatarUrl ?? ''), // Xử lý nullable avatarUrl
      ]);
      // Lưu trạng thái đăng nhập vào SharedPreferences (không nhạy cảm)
      await _sharedPreferences.setBool('isLogin', true);
    } catch (e) {
      // Bắt lỗi cụ thể hơn và ném lại với thông báo rõ ràng
      print('Error saving user authentication: $e'); // In ra lỗi để debug
      throw Exception('Failed to save user authentication: ${e.toString()}');
    }
  }

  // Cập nhật thông tin người dùng
  static Future<void> updateUserAuthentication(User userModel) async {
    try {
      await Future.wait([
        _storage.write(key: 'userName', value: userModel.name), // name là non-nullable
        _storage.write(key: 'userEmail', value: userModel.email ?? ''), // Cập nhật email nếu có
        _storage.write(key: 'phoneNumber', value: userModel.phone ?? ''), // Cập nhật phone nếu có
        _storage.write(key: 'avatarUrl', value: userModel.avatarUrl ?? ''), // Cập nhật avatar nếu có
        _storage.write(key: 'userRole', value: userModel.role.toString()), // Cập nhật role nếu cần
      ]);
    } catch (e) {
      print('Error updating user authentication: $e'); // In ra lỗi để debug
      throw Exception('Failed to update user authentication: ${e.toString()}');
    }
  }

  // Xóa thông tin người dùng
  static Future<void> clearUser() async {
    try {
      // Chỉ xóa các key liên quan đến người dùng
      await Future.wait([
        _storage.delete(key: 'token'),
        _storage.delete(key: 'userId'),
        _storage.delete(key: 'userName'),
        _storage.delete(key: 'userRole'),
        _storage.delete(key: 'userEmail'),
        _storage.delete(key: 'phoneNumber'),
        _storage.delete(key: 'avatarUrl'),
        _sharedPreferences.remove('isLogin'),
      ]);
    } catch (e) {
      print('Error clearing user data: $e'); // In ra lỗi để debug
      throw Exception('Failed to clear user data: ${e.toString()}');
    }
  }

  // Kiểm tra trạng thái đăng nhập
  static Future<bool> isAuthenticatedUser() async {
    try {
      final token = await _storage.read(key: 'token');
      // Token không null và không rỗng thì coi là đã đăng nhập
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking user authentication status: $e'); // In ra lỗi để debug
      return false; // Nếu có lỗi, coi như chưa đăng nhập
    }
  }

  // Lấy token
  static Future<String?> getUserToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      print('Error getting user token: $e'); // In ra lỗi để debug
      return null; // Trả về null nếu lỗi hoặc không có token
    }
  }

  // Lấy User ID
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: 'userId');
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Lấy User Role
  static Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: 'userRole');
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Lấy User Name
  static Future<String?> getUserName() async {
    try {
      return await _storage.read(key: 'userName');
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Lấy User Email
  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: 'userEmail');
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  // Lấy Phone Number
  static Future<String?> getPhoneNumber() async {
    try {
      return await _storage.read(key: 'phoneNumber');
    } catch (e) {
      print('Error getting phone number: $e');
      return null;
    }
  }

  // Lấy Avatar URL
  static Future<String?> getAvatarUrl() async {
    try {
      return await _storage.read(key: 'avatarUrl');
    } catch (e) {
      print('Error getting avatar URL: $e');
      return null;
    }
  }

  // --- HÀM MỚI: Lấy đối tượng User hoàn chỉnh từ bộ nhớ bảo mật ---
  static Future<User?> getUser() async {
    try {
      final userId = await _storage.read(key: 'userId');
      final name = await _storage.read(key: 'userName');
      final email = await _storage.read(key: 'userEmail');
      final phone = await _storage.read(key: 'phoneNumber');
      final roleString = await _storage.read(key: 'userRole');
      final token = await _storage.read(key: 'token');
      final avatarUrl = await _storage.read(key: 'avatarUrl');

      // Các trường createdAt và lastLoginAt thường không được lưu trong local storage
      // nếu không có lý do cụ thể. Bạn có thể thêm chúng nếu bạn lưu chúng.
      // Hiện tại, chúng ta sẽ gán giá trị mặc định hoặc null.
      final DateTime? createdAt = null; // Hoặc DateTime.now() nếu bạn muốn một giá trị mặc định
      final DateTime? lastLoginAt = null;

      if (userId != null && name != null && roleString != null) {
        return User(
          userId: userId,
          name: name,
          email: email, // email có thể null
          phone: phone, // phone có thể null
          passwordHash: null, // Không bao giờ lấy hash từ client storage
          role: UserRoleExtension.fromString(roleString),
          token: token, // token có thể null
          avatarUrl: avatarUrl, // avatarUrl có thể null
          createdAt: createdAt ?? DateTime.now(), // Cung cấp giá trị mặc định nếu null
          lastLoginAt: lastLoginAt,
        );
      }
      return null; // Trả về null nếu không đủ thông tin để tạo User object
    } catch (e) {
      print('Error retrieving user from storage: $e');
      return null;
    }
  }
}