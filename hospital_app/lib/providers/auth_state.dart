// lib/providers/auth_state.dart
// Enum để định nghĩa các trạng thái xác thực có thể có
enum AuthStatus {
  initial,      // Trạng thái ban đầu, chưa làm gì cả
  loading,      // Đang trong quá trình đăng nhập
  authenticated,// Đã đăng nhập thành công
  unauthenticated // Đăng nhập thất bại hoặc đã đăng xuất
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? userRole; // Lưu vai trò của người dùng khi đăng nhập thành công

  const AuthState({
    required this.status,
    this.errorMessage,
    this.userRole,
  });

  // Một factory constructor để tạo trạng thái ban đầu
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  // Một phương thức copyWith để dễ dàng tạo ra một trạng thái mới
  // dựa trên trạng thái cũ mà không cần thay đổi tất cả các thuộc tính.
  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userRole,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userRole: userRole ?? this.userRole,
    );
  }
}