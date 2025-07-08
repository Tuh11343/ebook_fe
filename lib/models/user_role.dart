enum UserRole {
  reader, // Vai trò mặc định cho người dùng thông thường
  admin, // Quản trị viên (có toàn quyền)
}

// Extension để dễ dàng chuyển đổi qua lại giữa enum và String/int (nếu cần cho DB/API)
extension UserRoleExtension on UserRole {

  String toShortString() {
    return toString().split('.').last; // Ví dụ: UserRole.admin -> "admin"
  }

  // Phương thức để chuyển đổi từ String sang UserRole
  static UserRole fromString(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'reader':
        return UserRole.reader;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.reader; // Mặc định là 'reader' nếu không khớp
    }
  }
}