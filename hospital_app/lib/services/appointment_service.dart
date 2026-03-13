// lib/services/appointment_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/services/dio_client.dart'; // chỉnh path cho đúng
import 'package:hospital_app/models/appointment.dart';


final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final dio = DioClient().dio; // dùng singleton đã gắn env + token + refresh
  return AppointmentService(dio);
});

class AppointmentService {
  AppointmentService(this._dio);
  final Dio _dio;

  String _extractErrorMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        // Ưu tiên lỗi có key 'error' (từ các action của chúng ta)
        if (data.containsKey('error')) {
          return data['error'].toString();
        }
        // Sau đó đến các lỗi validation khác
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
        final errorMessages = data.values.first;
        if (errorMessages is List && errorMessages.isNotEmpty) {
          return errorMessages.first.toString();
        }
      }
      return data.toString();
    } catch (_) {
      return 'Lỗi không xác định từ máy chủ.';
    }
  }

  Future<List<Appointment>> getDoctorAppointments(int doctorId) async {
    try {
      final response = await _dio.get(
        '/appointments/',
        queryParameters: {'doctor_id': doctorId},
      );
      
      final data = response.data;
      List<dynamic> results = [];
      if (data is List) results = data;
      else if (data is Map && data['results'] is List) results = data['results'] as List;
      
      return results.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi tải lịch hẹn của bác sĩ: $e');
      rethrow;
    }
  }


 


Future<void> createAppointment({
  required int doctorId,
  required DateTime appointmentTime,
  required String reason,
  int? patientId,
  List<int>? serviceIds,
  // required int serviceId,
}) async {
  final payload = <String, dynamic>{
    'doctor_id': doctorId,
    'appointment_time': appointmentTime.toIso8601String(),
    'reason': reason,
    
    // 'service_id': serviceId,
  };
  if (patientId != null) payload['patient_id'] = patientId;
  if (serviceIds != null && serviceIds.isNotEmpty) {
      payload['services'] = serviceIds; 
    }
  try {
    await _dio.post('/appointments/', data: payload);
  } on DioException catch (e) {
    // Dùng helper đã có để rút message đẹp
    throw _extractErrorMessage(e.response?.data);
  } catch (e) {
    rethrow;
  }
}
 

  Future<List<Appointment>> getMyAppointments() async {
    try {
      // 1. Sửa lại endpoint: Xóa '/my/' vì ViewSet đã tự lọc
      final response = await _dio.get('/appointments/');
      final data = response.data;
      
      List<dynamic> results = [];
      if (data is List) {
        results = data;
      } else if (data is Map && data['results'] is List) {
        results = data['results'] as List;
      }
      
      // 2. Chuyển đổi dữ liệu JSON thô thành danh sách các đối tượng Appointment
      return results.map((json) => Appointment.fromJson(json)).toList();

    } catch (e) {
      print('Lỗi khi tải lịch hẹn: $e');
      // Ném lại lỗi để FutureProvider có thể bắt và hiển thị
      rethrow;
    }
  }
  
  //bệnh nhân xác nhận
  Future<void> patientConfirmAppointment(int appointmentId) async {
    try {
      await _dio.post('/appointments/$appointmentId/patient_confirm/');
    } on DioException catch (e) {
      throw _extractErrorMessage(e.response?.data);
    }
  }



  //checkin
  Future<void> checkInAppointment(int appointmentId) async {
    try {
      await _dio.post('/appointments/$appointmentId/check_in/');
    } on DioException catch (e) {
      throw _extractErrorMessage(e.response?.data);
    }
  }

  //hoàn thành
  Future<void> completeAppointment(int appointmentId) async {
    try {
      await _dio.post('/appointments/$appointmentId/complete/');
    } on DioException catch (e) {
      throw _extractErrorMessage(e.response?.data);
    }
  }

  //lễ tân xác nhận
  Future<void> confirmAppointment(int appointmentId) async {
    try {
      await _dio.post('/appointments/$appointmentId/confirm/');
    } on DioException catch (e) {
      throw _extractErrorMessage(e.response?.data);
    }
  }
  
  //lễ tân từ chối
  Future<void> rejectAppointment(int appointmentId, String reason) async {
    try {
      await _dio.post('/appointments/$appointmentId/reject/', data: {'reason': reason});
    } on DioException catch (e) {
      throw _extractErrorMessage(e.response?.data);
    }
  }

  Future<void> cancelAppointment(int appointmentId) async {
    try {
      await _dio.post('/appointments/$appointmentId/cancel/');
    } on DioException catch (e) {
      throw _extractErrorMessage(e.response?.data);
    }
  }


}
