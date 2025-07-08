import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, success, failure }

// Enum để phân biệt loại hành động xác thực đang diễn ra hoặc đã hoàn thành
enum AuthActionType {
  none,       // Không có hành động nào đang diễn ra
  signIn,     // Hành động đăng nhập
  signUp,     // Hành động đăng ký
  signOut,    // Hành động đăng xuất
  // ... Có thể thêm các loại hành động khác như resetPassword, verifyEmail, v.v.
}

// Lớp AuthState để quản lý trạng thái xác thực toàn cục của ứng dụng
class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;   // Thông báo lỗi liên quan đến hành động vừa thực hiện
  final String? successMessage; // Thông báo thành công liên quan đến hành động vừa thực hiện
  final AuthActionType actionType; // Loại hành động xác thực hiện tại (hoặc vừa hoàn thành)

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.actionType = AuthActionType.none,
  });

  // Phương thức copyWith giúp tạo một AuthState mới với các thuộc tính được cập nhật
  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? successMessage,
    AuthActionType? actionType,
  }) {
    return AuthState(
      status: status ?? this.status,
      // Đặt errorMessage và successMessage là null nếu không được cung cấp giá trị mới,
      // để đảm bảo chúng được xóa sau khi xử lý.
      errorMessage: errorMessage,
      successMessage: successMessage,
      actionType: actionType ?? this.actionType,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage, actionType];
}