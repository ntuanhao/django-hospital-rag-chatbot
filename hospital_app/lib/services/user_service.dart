// lib/services/user_service.dart (Nếu chưa có thì tạo mới)
import 'package:dio/dio.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/services/dio_client.dart';

class UserService {
  final Dio _dio = DioClient().dio;

  
  // Future<List<UserAccount>> getAllUsers() async {
  //   try {
  //     // Admin gọi endpoint /users/, backend sẽ trả về tất cả user
  //     final response = await _dio.get('/users/');

  //     if (response.statusCode == 200) {
  //       // Chuyển đổi danh sách JSON thành danh sách các đối tượng UserAccount
  //       List<dynamic> userListJson = response.data as List;
  //       return userListJson.map((json) => UserAccount.fromJson(json)).toList();
  //     } else {
  //       throw 'Không thể tải danh sách người dùng.';
  //     }
  //   } catch (e) {
  //     throw 'Đã xảy ra lỗi khi lấy danh sách người dùng.';
  //   }
  // }

  Future<List<UserAccount>> getAllUsers({String searchQuery = '', String? role}) async {
    try {
      // Xây dựng các tham số query động
      final queryParameters = <String, dynamic>{
        // Chỉ thêm vào query nếu giá trị không rỗng/null
        if (searchQuery.isNotEmpty) 'search': searchQuery,
        if (role != null && role.isNotEmpty) 'role': role,
      };

      final response = await _dio.get('/users/', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> userList = [];
        // Xử lý cả trường hợp có phân trang và không có
        if (data is List) {
          userList = data;
        } else if (data is Map && data['results'] is List) {
          userList = data['results'];
        }
        return userList.map((json) => UserAccount.fromJson(json)).toList();
      } else {
        throw 'Không thể tải danh sách người dùng.';
      }
    } catch (e) {
      print('Lỗi khi tải danh sách người dùng: $e');
      rethrow;
    }
  }


 Future<UserAccount> getMe() async {
    try {
      final response = await _dio.get('/users/me/');
      return UserAccount.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<UserAccount> updateMe(Map<String, dynamic> data, {String? avatarPath}) async {
    try {
      // Nếu có avatarPath, chúng ta sẽ tạo FormData
      if (avatarPath != null) {
        final formData = FormData.fromMap({
          ...data,
          'avatar': await MultipartFile.fromFile(avatarPath),
        });
        final response = await _dio.patch('/users/me/', data: formData);
        return UserAccount.fromJson(response.data);
      } else {
        // Nếu không có avatar, gửi JSON như bình thường
        final response = await _dio.patch('/users/me/', data: data);
        return UserAccount.fromJson(response.data);
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<UserAccount> getUserById(int userId) async {
    try {
      final response = await _dio.get('/users/$userId/');
      return UserAccount.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  //Admin
  Future<UserAccount> createUser({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/users/', // Endpoint tạo user của Admin
        data: {
          'username': username,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'role': role,
          'phone_number': phoneNumber,
        },
      );
      return UserAccount.fromJson(response.data);
    } on DioException catch (e) {
      // Cố gắng trích xuất lỗi validation từ Django
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        // Lấy thông báo lỗi đầu tiên tìm thấy
        final firstError = errors.values.first;
        if (firstError is List) {
          throw firstError.first.toString();
        }
        throw firstError.toString();
      }
      throw 'Đã xảy ra lỗi không xác định.';
    } catch (e) {
      rethrow;
    }
  }

  Future<UserAccount> updateUserById(int userId, Map<String, dynamic> data) async {
    try {
      // Admin sẽ gửi một request PATCH đến ID của user cụ thể
      final response = await _dio.patch('/users/$userId/', data: data);
      return UserAccount.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List) {
          throw firstError.first.toString();
        }
        throw firstError.toString();
      }
      throw 'Đã xảy ra lỗi không xác định.';
    } catch (e) {
      rethrow;
    }
  }
  
}