import 'package:ebook_tuh/models/user_role.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class User extends Equatable {
  final String userId;
  final String name;
  final String? phone; // Có thể null
  final String? email; // Có thể null
  final String? passwordHash; // Không lưu plaintext
  final UserRole role;
  final String? token; // Có thể null
  final String? avatarUrl; // Có thể null
  final DateTime? createdAt;
  final DateTime? lastLoginAt; // Có thể null

  const User({
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    this.passwordHash,
    this.role = UserRole.reader,
    this.token,
    this.avatarUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Factory constructor để tạo User từ Map (JSON/DB)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Ưu tiên camelCase, sau đó là snake_case, với null safety
      userId: (json['userId'] as String?) ?? (json['user_id'] as String?) ?? '',
      name: json['name'] as String? ?? '', // Đảm bảo không null
      phone: json['phone'] as String?, // Có thể null
      email: json['email'] as String?, // Có thể null
      passwordHash: (json['passwordHash'] as String?) ?? (json['password_hash'] as String?), // Có thể null
      role: UserRoleExtension.fromString((json['role'] as String?) ?? 'reader'), // Default role
      token: json['token'] as String?, // Có thể null
      avatarUrl: (json['avatarUrl'] as String?) ?? (json['avatar_url'] as String?), // Có thể null
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : (json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'] as String)
          : (json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null),
    );
  }

  // Chuyển đổi User thành Map (JSON/DB)
  Map<String, dynamic> toJson() {
    return {
      // Xuất ra camelCase (giả sử API backend của bạn đã hỗ trợ camelCase)
      'userId': userId.isEmpty ? const Uuid().v4() : userId, // Đổi từ 'user_id'
      'name': name,
      'phone': phone,
      'email': email,
      'passwordHash': passwordHash, // Đổi từ 'password_hash'
      'role': role.toShortString(),
      'token': token,
      'avatarUrl': avatarUrl, // Đổi từ 'avatar_url'
      'createdAt': createdAt?.toIso8601String(), // Đổi từ 'created_at'
      'lastLoginAt': lastLoginAt?.toIso8601String(), // Đổi từ 'last_login_at'
    };
  }

  // copyWith để dễ dàng tạo bản sao với các thay đổi
  User copyWith({
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? passwordHash,
    UserRole? role,
    String? token,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      token: token ?? this.token,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    phone,
    email,
    passwordHash,
    role,
    token,
    avatarUrl,
    createdAt,
    lastLoginAt,
  ];
}