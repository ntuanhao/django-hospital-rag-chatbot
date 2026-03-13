// // lib/services/patient_service.dart
import 'package:dio/dio.dart';
// import 'package:hospital_app/models/encounter.dart';
// import 'package:hospital_app/services/dio_client.dart';
// import 'package:hospital_app/models/user_account.dart';
// class PatientService {
//   final Dio _dio = DioClient().dio;

//   // Lấy tất cả các lần khám (encounters) của một bệnh nhân
//   Future<List<Encounter>> getPatientEncounters(int patientId) async {
//     try {
//       // Backend cần có khả năng lọc encounter theo patient_id
//       final response = await _dio.get(
//         '/encounters/',
//         queryParameters: {'patient_id': patientId},
//       );
      
//       if (response.statusCode == 200) {
//         List<dynamic> data = response.data as List;
//         return data.map((json) => Encounter.fromJson(json)).toList();
//       } else {
//         throw 'Không thể tải lịch sử khám.';
//       }
//     } catch (e) {
//       throw 'Đã xảy ra lỗi khi tải lịch sử khám.';
//     }
//   }

//   Future<List<UserAccount>> getAllPatients() async {
//     try {
//       final response = await _dio.get(
//         '/users/',
//         queryParameters: {'role': 'PATIENT'},
        
//       );
//       if (response.statusCode == 200) {
//         List<dynamic> data = response.data as List;
//         return data.map((json) => UserAccount.fromJson(json)).toList();
//       } else {
//         throw 'Không thể tải danh sách bệnh nhân.';
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<List<Encounter>> getMyEncounters() async {
//     try {
//       // Backend sẽ tự lọc dựa trên token
//       final response = await _dio.get('/encounters/');
      
//       if (response.statusCode == 200) {
//         List<dynamic> data = response.data as List;
//         return data.map((json) => Encounter.fromJson(json)).toList();
//       } else {
//         throw 'Không thể tải kết quả khám.';
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
  
// }
// lib/services/patient_service.dart

import 'package:hospital_app/models/encounter.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/services/dio_client.dart';

class PatientService {
  final Dio _dio = DioClient().dio;

  // Lấy danh sách tất cả các bệnh nhân, có hỗ trợ tìm kiếm
  Future<List<UserAccount>> getAllPatients({String searchQuery = ''}) async {
    try {
      final response = await _dio.get(
        '/users/',
        queryParameters: {
          'role': 'PATIENT',
          'search': searchQuery, // Gửi tham số tìm kiếm đến backend
        },
      );
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
        throw 'Không thể tải danh sách bệnh nhân.';
      }
    } catch (e) {
      print('Lỗi khi tải danh sách bệnh nhân: $e');
      rethrow;
    }
  }

  // Lấy lịch sử khám của một bệnh nhân cụ thể (dành cho Bác sĩ/Lễ tân xem)
  Future<List<Encounter>> getPatientEncounters(int patientId) async {
    try {
      // Backend cần hỗ trợ lọc encounter theo appointment__patient_id
      final response = await _dio.get(
        '/encounters/',
        queryParameters: {'appointment__patient': patientId},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List;
        return data.map((json) => Encounter.fromJson(json)).toList();
      } else {
        throw 'Không thể tải lịch sử khám.';
      }
    } catch (e) {
      throw 'Đã xảy ra lỗi khi tải lịch sử khám.';
    }
  }

  // Lấy lịch sử khám của chính người dùng đang đăng nhập (dành cho Bệnh nhân)
  Future<List<Encounter>> getMyEncounters() async {
    try {
      // Backend sẽ tự lọc dựa trên token
      final response = await _dio.get('/encounters/');
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List;
        return data.map((json) => Encounter.fromJson(json)).toList();
      } else {
        throw 'Không thể tải kết quả khám.';
      }
    } catch (e) {
      rethrow;
    }
  }
}