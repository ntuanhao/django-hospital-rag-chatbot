// lib/utils/api_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Lấy base URL từ file .env, nếu không có thì dùng một giá trị mặc định
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  // Các endpoint xác thực
  static const String loginUrl = '/auth/login/';
  static const String registerUrl = '/auth/register/';
  static const String refreshTokenUrl = '/token/refresh/'; // Endpoint mặc định của SimpleJWT

}