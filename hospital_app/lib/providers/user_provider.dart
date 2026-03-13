// lib/providers/user_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/services/user_service.dart';
import 'package:equatable/equatable.dart';
// import 'package:hospital_app/models/user_account.dart';

// Provider cho service (Không thay đổi)
final userServiceProvider = Provider((ref) => UserService());

// <<< SỬA LẠI HOÀN TOÀN PROVIDER NÀY >>>
// Provider để lấy và quản lý thông tin của người dùng đang đăng nhập
final userProfileProvider = 
    AsyncNotifierProvider.autoDispose<UserProfileNotifier, UserAccount>(
        UserProfileNotifier.new);


final userDetailProvider =
    FutureProvider.family<UserAccount, int>((ref, int patientId) async {
  final service = ref.watch(userServiceProvider);
  return service.getUserById(patientId);
});

class UserProfileNotifier extends AsyncNotifier<UserAccount> {
  // build() sẽ tự động được gọi để lấy dữ liệu lần đầu
  @override
  Future<UserAccount> build() async {
    final userService = ref.read(userServiceProvider);
    return userService.getMe();
  }

  // Hành động để tải lại profile (nếu cần)
  Future<void> refreshProfile() async {
    // Đặt state về loading trong khi fetch lại
    state = const AsyncLoading();
    // Gán lại state bằng kết quả fetch mới, .guard sẽ tự bắt lỗi
    state = await AsyncValue.guard(() async {
      return ref.read(userServiceProvider).getMe();
    });
  }

  
  // Future<void> updateProfile(Map<String, dynamic> data) async { ... }
  Future<bool> updateProfile(Map<String, dynamic> data, {String? avatarPath}) async {
    // Lấy service trực tiếp từ ref
    final userService = ref.read(userServiceProvider);
    
    // Đặt trạng thái loading trong khi chờ cập nhật
    state = const AsyncLoading();

    // Dùng AsyncValue.guard để bắt lỗi và cập nhật state
    state = await AsyncValue.guard(() async {
      return userService.updateMe(data);
    });
    state = await AsyncValue.guard(() async {
      return ref.read(userServiceProvider).updateMe(data, avatarPath: avatarPath);
    });
    // Trả về true nếu không có lỗi, false nếu có lỗi
    return !state.hasError;
  }

  // Lấy thông tin của 1 bệnh nhân (UserAccount) theo id bất kỳ
}


//Phần Admin

class UserFilter extends Equatable {
  final String searchQuery;
  final String? role; // ADMIN, DOCTOR, RECEPTIONIST, PATIENT

  const UserFilter({this.searchQuery = '', this.role});

  @override
  List<Object?> get props => [searchQuery, role];
}

// 2. Tạo Provider chính
// Sử dụng .family để nó có thể nhận vào đối tượng UserFilter
final adminUserListProvider = 
  FutureProvider.autoDispose.family<List<UserAccount>, UserFilter>((ref, filter) {
    // Gọi đến service với các tham số từ filter
    final userService = ref.watch(userServiceProvider);
    // Chúng ta sẽ cần cập nhật UserService để nhận các tham số này
    return userService.getAllUsers(
      searchQuery: filter.searchQuery,
      role: filter.role,
    );
});

final adminCreateUserProvider = 
    AsyncNotifierProvider.autoDispose<AdminCreateUserNotifier, void>(
        AdminCreateUserNotifier.new);

class AdminCreateUserNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Không cần làm gì ở đây, state mặc định là AsyncData(null)
  }

  Future<void> createUser({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String role, // DOCTOR, RECEPTIONIST, etc.
    String? phoneNumber,
  }) async {
    // Đặt state về loading
    state = const AsyncLoading();

    // Dùng guard để gọi service và bắt lỗi
    state = await AsyncValue.guard(() async {
      // Chúng ta sẽ cần thêm hàm `createUser` vào UserService
      await ref.read(userServiceProvider).createUser(
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        phoneNumber: phoneNumber,
      );
    });

    // Nếu tạo thành công, làm mới lại danh sách user để nó tự cập nhật
    if (!state.hasError) {
      // Dùng ref.invalidate để báo cho provider danh sách biết rằng dữ liệu đã cũ
      // và cần được fetch lại.
      // Chúng ta cần tìm một cách để làm mới tất cả các filter có thể có.
      // Cách đơn giản nhất là dùng `ref.refresh`.
      ref.invalidate(adminUserListProvider);
    }
  }
}



final adminUserDetailProvider =
  AsyncNotifierProvider.autoDispose<AdminUserDetailNotifier, UserAccount>(
    AdminUserDetailNotifier.new,
  );

class AdminUserDetailNotifier extends AsyncNotifier<UserAccount> {
  int? _userId;

  @override
  FutureOr<UserAccount> build() async {
    // Để tránh lỗi crash, chúng ta sẽ trả về một Future không bao giờ hoàn thành
    // Điều này sẽ giữ provider ở trạng thái loading cho đến khi `fetch` được gọi.
    return Completer<UserAccount>().future;
  }

  Future<void> fetch(int userId) async {
    _userId = userId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userServiceProvider).getUserById(userId),
    );
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    final id = _userId;
    if (id == null) return;
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userServiceProvider).updateUserById(id, data),
    );

    if (!state.hasError) {
      ref.invalidate(adminUserListProvider);
    }
  }
}

// final adminUserDetailProvider =
//   AsyncNotifierProvider<AdminUserDetailNotifier, UserAccount>(
//     AdminUserDetailNotifier.new,
//   );

// class AdminUserDetailNotifier extends AsyncNotifier<UserAccount> {
//   int? _userId;

//   @override
//   FutureOr<UserAccount> build() async {
//     // Chưa có userId thì trả về trạng thái loading/placeholder tuỳ bạn
//     throw UnimplementedError('Call fetch(userId) first');
//   }

//   Future<void> fetch(int userId) async {
//     _userId = userId;
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(
//       () => ref.read(userServiceProvider).getUserById(userId),
//     );
//   }

//   Future<void> updateUser(Map<String, dynamic> data) async {
//     final id = _userId;
//     if (id == null) return;
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(
//       () => ref.read(userServiceProvider).updateUserById(id, data),
//     );
//     if (!state.hasError) ref.invalidate(adminUserListProvider);
//   }
// }


