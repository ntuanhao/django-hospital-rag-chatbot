// lib/services/doctor_service.dart
import 'package:dio/dio.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/services/dio_client.dart';
import 'package:hospital_app/models/recurring_schedule.dart';
import 'package:hospital_app/models/service.dart';
import 'package:flutter/material.dart';

class DoctorService {
  final Dio _dio = DioClient().dio;

  

  // Future<List<UserAccount>> getDoctors({String searchQuery = '',int? specialtyId,}) async {
    
  //   try {
  //     final response = await _dio.get(
  //       '/users/',
  //       queryParameters: {
  //         'role': 'DOCTOR',
  //         'search': searchQuery, // Sử dụng tham số ở đây
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = response.data as List;
  //       return data.map((json) => UserAccount.fromJson(json)).toList();
  //     } else {
  //       throw 'Không thể tải danh sách bác sĩ.';
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<List<Service>> getServicesForDoctor(int doctorId) async {
    try {
      final response = await _dio.get('/users/$doctorId/services/');
      List<dynamic> data = response.data as List;
      return data.map((json) => Service.fromJson(json)).toList();
    } catch (e) { rethrow; }
  }

  Future<List<UserAccount>> getDoctors({
    String searchQuery = '',
    int? specialtyId,
  }) async {
    try {
      final response = await _dio.get(
        '/users/',
        queryParameters: {
          'role': 'DOCTOR',

          // chỉ gửi 'search' nếu có gõ từ khóa
          if (searchQuery.isNotEmpty) 'search': searchQuery,

          // QUAN TRỌNG nè: phải khớp với backend
          if (specialtyId != null)
            'doctor_profile_specialty': specialtyId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((e) => UserAccount.fromJson(e)).toList();
      } else {
        throw 'Không thể tải danh sách bác sĩ';
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<List<RecurringSchedule>> getDoctorSchedule(int doctorId) async {
    try {
      // Gọi đến endpoint mới là 'recurring-schedules'
      final response = await _dio.get(
        '/recurring-schedules/',
        queryParameters: {'doctor_id': doctorId},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List;
        // Sử dụng model mới để phân tích JSON
        return data.map((json) => RecurringSchedule.fromJson(json)).toList();
      } else {
        throw 'Không thể tải lịch làm việc của bác sĩ.';
      }
    } catch (e) {
      throw 'Đã xảy ra lỗi khi tải lịch làm việc.';
    }
  }
  
  Future<List<RecurringSchedule>> getMyRecurringSchedule() async {
    try {
      // Không cần truyền doctor_id, backend sẽ tự lọc
      final response = await _dio.get('/recurring-schedules/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List;
        return data.map((json) => RecurringSchedule.fromJson(json)).toList();
      } else {
        throw 'Không thể tải lịch làm việc.';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserAccount>> getMyPatients() async {
    try {
      // Gọi đến action mới
      final response = await _dio.get('/users/my_patients/');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List;
        return data.map((json) => UserAccount.fromJson(json)).toList();
      } else {
        throw 'Không thể tải danh sách bệnh nhân.';
      }
    } catch (e) {
      rethrow;
    }
  }

  //Admin
  Future<RecurringSchedule> createSchedule({
    required int doctorId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    try {
      // Chuyển TimeOfDay thành chuỗi "HH:MM:SS"
      final formatTime = (TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
      
      final response = await _dio.post('/recurring-schedules/', data: {
        'doctor': doctorId,
        'day_of_week': dayOfWeek,
        'start_time': formatTime(startTime),
        'end_time': formatTime(endTime),
      });
      return RecurringSchedule.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data.toString() ?? 'Không thể tạo lịch làm việc.';
    }
  }

  // 2. Xóa một lịch làm việc
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await _dio.delete('/recurring-schedules/$scheduleId/');
    } catch (e) {
      throw 'Không thể xóa lịch làm việc.';
    }
  }
}