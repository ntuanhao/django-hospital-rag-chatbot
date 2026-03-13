// // lib/services/dio_client.dart
// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class DioClient {
//   // Singleton pattern để đảm bảo chỉ có một instance của DioClient
//   DioClient._();
//   static final DioClient _instance = DioClient._();
//   factory DioClient() => _instance;

//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   // Tạo một instance của Dio với các cấu hình cơ bản
//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: dotenv.env['API_BASE_URL']!, // Lấy URL từ file .env
//       connectTimeout: const Duration(seconds: 15),
//       receiveTimeout: const Duration(seconds: 15),
//       responseType: ResponseType.json,
//     ),
//   )..interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // Trước mỗi request, lấy token từ storage
//           final token = await _instance._secureStorage.read(key: 'access_token');

//           // Nếu có token, đính kèm vào header Authorization
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
          
//           // Tiếp tục gửi request
//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           // Không làm gì đặc biệt khi có response thành công, chỉ cần cho qua
//           return handler.next(response);
//         },
//         onError: (DioException e, handler) async {
//           // Xử lý khi có lỗi xảy ra
//           // Ví dụ: nếu lỗi là 401 (Unauthorized), có thể thực hiện logic refresh token ở đây
//           if (e.response?.statusCode == 401) {
//             // TODO: Triển khai logic refresh token sau này
//             print('Token hết hạn hoặc không hợp lệ.');
//           }
          
//           // Chuyển lỗi đi tiếp để nơi gọi có thể xử lý
//           return handler.next(e);
//         },
//       ),
//     );

//   // Getter để các service khác có thể truy cập vào instance Dio đã được cấu hình
//   Dio get dio => _dio;
// }

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class DioClient {
  // ===== Singleton: giữ nguyên cách dùng cũ: DioClient().dio =====
  DioClient._internal() {
    _init();
  }
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  void _init() {
    dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL']!, // đổi <SERVER_IP> thành IP máy chạy Django
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      // 1) Gắn Bearer token cho mọi request
      // onRequest: (options, handler) async {
      //   final token = await _storage.read(key: 'access_token');
      //   if (token != null && token.isNotEmpty) {
      //     options.headers['Authorization'] = 'Bearer $token';
      //   }
      //   return handler.next(options);
      // },
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          // DEBUG: xem có gắn token thật không
          // ignore: avoid_print
          print('[AUTH] ${options.method} ${options.path} -> Bearer ${token.substring(0, 12)}...');
        } else {
          // ignore: avoid_print
          print('[AUTH] ${options.method} ${options.path} -> NO TOKEN');
        }
        return handler.next(options);
      },


      // 2) Tự refresh khi 401
      onError: (e, handler) async {
        final status = e.response?.statusCode ?? 0;

        // Chỉ thử refresh nếu là 401 và chưa thử refresh trước đó
        final isAuthError = status == 401;
        final alreadyRetried = e.requestOptions.extra['retried'] == true;

        if (isAuthError && !alreadyRetried) {
          final refresh = await _storage.read(key: 'refresh_token');
          if (refresh != null && refresh.isNotEmpty) {
            try {
              final refreshRes = await dio.post('/auth/refresh/', data: {
                'refresh': refresh,
              });

              final newAccess = refreshRes.data['access'] as String?;
              if (newAccess != null && newAccess.isNotEmpty) {
                await _storage.write(key: 'access_token', value: newAccess);

                // Gửi lại request cũ với token mới
                final RequestOptions req = e.requestOptions;
                req.headers['Authorization'] = 'Bearer $newAccess';
                req.extra['retried'] = true; // đánh dấu đã retry 1 lần
                final clone = await dio.fetch(req);
                return handler.resolve(clone);
              }
            } catch (refreshError) {
    // Chỉ xóa token nếu lỗi refresh là lỗi xác thực (401, 403),
    // không phải lỗi mạng hay lỗi server (404, 500).
    if (refreshError is DioException && 
        (refreshError.response?.statusCode == 401 || refreshError.response?.statusCode == 403)) {
        
        print('[AUTH] Refresh token không hợp lệ hoặc đã hết hạn, đăng xuất người dùng.');
        await _storage.delete(key: 'access_token');
        await _storage.delete(key: 'refresh_token');
    } else {
        // Đối với các lỗi khác (như 404 Not Found), chỉ in ra log mà không xóa token.
        // Điều này cho phép request gốc tiếp tục đi đến handler.next(e) và được xử lý
        // ở tầng service/provider, thay vì gây ra hiệu ứng đăng xuất hàng loạt.
        print('[AUTH] Lỗi không phải lỗi xác thực khi refresh token: $refreshError');
    }
}
          }
        }

        return handler.next(e);
      },
    ));
  }
}


