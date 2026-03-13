// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/services/dio_client.dart';

class AuthService {
  // Lấy instance Dio đã được cấu hình từ DioClient
  final Dio _dio = DioClient().dio;

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      // Thực hiện request POST đến endpoint /auth/login/
      final response = await _dio.post(
        '/auth/login/',
        data: {
          'username': username,
          'password': password,
        },
      );

      // Nếu request thành công (statusCode 200)
      if (response.statusCode == 200) {
        // Chuyển đổi dữ liệu JSON trả về thành đối tượng LoginResponse
        return LoginResponse.fromJson(response.data);
      } else {
        // Ném ra lỗi nếu status code không phải 200
        throw 'Đăng nhập thất bại. Vui lòng thử lại.';
      }
    } on DioException catch (e) {
      // Bắt lỗi cụ thể từ Dio (ví dụ: 401 Unauthorized, không có mạng...)
      final errorMessage = e.response?.data['detail'] ?? 'Lỗi không xác định. Vui lòng thử lại.';
      print('Lỗi DioException khi đăng nhập: $errorMessage');
      throw errorMessage;
    } catch (e) {
      // Bắt các lỗi khác
      print('Lỗi không xác định khi đăng nhập: $e');
      throw 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
  
  // <<< CẬP NHẬT HÀM REGISTER >>>
  Future<UserAccount> register({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    // Thêm các trường tùy chọn mới
    String? phoneNumber,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register/',
        data: {
          'username': username,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          // Thêm các trường mới vào body của request
          'phone_number': phoneNumber,
          'address': address,
          'gender': gender,
          'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        },
      );

      if (response.statusCode == 201) {
        return UserAccount.fromJson(response.data);
      } else {
        throw 'Đăng ký thất bại.';
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data.toString() ?? 'Lỗi không xác định.';
        print('Lỗi DioException khi đăng ký: $errorMessage');
      throw errorMessage;
    } catch (e) {
        print('Lỗi không xác định khi đăng ký: $e');
      throw 'Đăng ký thành công.';
    }
  }
}

