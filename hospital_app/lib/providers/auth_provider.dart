// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/auth_state.dart';
import 'package:hospital_app/services/auth_service.dart';

// 1. Tạo một provider toàn cục để truy cập AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 2. Tạo NotifierProvider chính
// Nó sẽ quản lý lớp AuthNotifier và trạng thái AuthState của nó
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);




class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;
  late final FlutterSecureStorage _secureStorage;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);
    _secureStorage = const FlutterSecureStorage();
    return AuthState.initial();
  }

  Future<void> login(String username, String password) async {
    // Reset state về loading, xóa lỗi cũ
    state = const AuthState(status: AuthStatus.loading);
    try {
      print('--- BẮT ĐẦU QUÁ TRÌNH LOGIN ---');
      print('Đang gọi AuthService.login với username: $username');
      
      final LoginResponse loginResponse = await _authService.login(
        username: username,
        password: password,
      );

      print('Login API thành công. Nhận được role: ${loginResponse.role}');
      print('Chuẩn bị lưu access token vào SecureStorage...');
      await _secureStorage.write(key: 'access_token', value: loginResponse.accessToken);
      await _secureStorage.write(key: 'refresh_token', value: loginResponse.refreshToken);
      
      print('Đã lưu token thành công. Cập nhật state sang AUTHENTICATED.');
      print('---------------------------------');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userRole: loginResponse.role,
      );
    } catch (e) {
      print('!!! LỖI TRONG QUÁ TRÌNH LOGIN !!!');
      print('Lỗi: ${e.toString()}');
      print('---------------------------------');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    // Reset state về loading, xóa lỗi cũ
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _authService.register(
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      // Reset về trạng thái ban đầu khi thành công
      state = AuthState.initial();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    state = AuthState.initial();
  }
}
