// lib/services/encounter_service.dart
import 'package:dio/dio.dart';
import 'package:hospital_app/services/dio_client.dart';

class EncounterService {
  final Dio _dio = DioClient().dio;

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

  // Hàm để tạo một bệnh án mới
  // Future<void> createEncounter({
  //   required int appointmentId,
  //   required String symptoms,
  //   required String diagnosis,
  // }) async {
  //   try {
  //     await _dio.post(
  //       '/encounters/',
  //       data: {
  //         'appointment': appointmentId, // Backend mong đợi key là 'appointment'
  //         'symptoms': symptoms,
  //         'diagnosis': diagnosis,
  //       },
  //     );
  //   } on DioException catch (e) {
  //     throw _extractErrorMessage(e.response?.data);
  //   }
  // }

  Future<void> createEncounter({
    required int appointmentId,
    required String symptoms,
    required String diagnosis,
    required List<Map<String, dynamic>> prescriptionItems,
    List<int>? serviceIds,
    String? prescriptionNotes, // Thêm ghi chú cho đơn thuốc
  }) async {
    try {
      // Xây dựng payload lồng nhau đúng như backend mong đợi
      final payload = {
        'appointment': appointmentId,
        'symptoms': symptoms,
        'diagnosis': diagnosis,
        'prescriptions': [ // Một danh sách các đơn thuốc
          {
            'notes': prescriptionNotes ?? 'Uống theo chỉ định.',
            'items': prescriptionItems, // Danh sách các chi tiết thuốc
          }
        ],
        'services_performed': serviceIds ?? [],
      };
      await _dio.post('/encounters/', data: payload);
    } on DioException catch (e) {
      throw _extractErrorMessage(e.response?.data);
    }
  }
}
  // TODO: Thêm hàm getEncounters(patientId) sau này