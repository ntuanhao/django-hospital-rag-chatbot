// lib/services/service_service.dart
import 'package:dio/dio.dart';
import 'package:hospital_app/models/service.dart';
import 'package:hospital_app/services/dio_client.dart';

class ServiceService {
  final Dio _dio = DioClient().dio;

  // Lấy danh sách dịch vụ, có thể lọc theo chuyên khoa
  // Future<List<Service>> getServices({int? specialtyId}) async {
  //   try {
  //     final queryParameters = <String, dynamic>{};
  //     // Nếu có specialtyId, thêm nó vào tham số truy vấn
  //     if (specialtyId != null) {
  //       queryParameters['specialty_id'] = specialtyId;
  //     }
      
  //     final response = await _dio.get('/services/', queryParameters: queryParameters);
      
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = response.data as List;
  //       return data.map((json) => Service.fromJson(json)).toList();
  //     } else {
  //       throw 'Không thể tải danh sách dịch vụ.';
  //     }
  //   } catch (e) {
  //     print('Lỗi khi tải dịch vụ: $e');
  //     rethrow;
  //   }
  // }

  Future<List<Service>> getServices({int? specialtyId}) async {
    try {
      // Xây dựng query parameters động
      final queryParameters = <String, dynamic>{
        if (specialtyId != null) 'specialty_id': specialtyId,
      };

      final response = await _dio.get('/services/', queryParameters: queryParameters);
      List<dynamic> data = response.data as List;
      return data.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Service> createService({
    required String name,
    required String price,
    required List<int> specialtyIds,
  }) async {
    try {
      final response = await _dio.post('/services/', data: {
        'name': name,
        'price': price,
        'specialties': specialtyIds,
      });
      return Service.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data.toString() ?? 'Không thể tạo dịch vụ.';
    }
  }

  Future<Service> updateService({
    required int id,
    required String name,
    required String price,
    required List<int> specialtyIds,
  }) async {
    try {
      final response = await _dio.put('/services/$id/', data: {
        'name': name,
        'price': price,
        'specialties': specialtyIds,
      });
      return Service.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data.toString() ?? 'Không thể cập nhật dịch vụ.';
    }
  }

  Future<void> deleteService(int id) async {
    try {
      await _dio.delete('/services/$id/');
    } catch (e) {
      throw 'Không thể xóa dịch vụ.';
    }
  }
  
}