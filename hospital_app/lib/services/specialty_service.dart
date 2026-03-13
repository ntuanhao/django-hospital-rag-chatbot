// lib/services/specialty_service.dart
import 'package:dio/dio.dart';
import 'package:hospital_app/models/specialty.dart';
import 'package:hospital_app/services/dio_client.dart';

class SpecialtyService {
  final Dio _dio = DioClient().dio;

  Future<List<Specialty>> getSpecialties() async {
    try {
      final response = await _dio.get('/specialties/');
      
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> specialtyList = [];
        if (data is List) {
          specialtyList = data;
        } else if (data is Map && data['results'] is List) {
          specialtyList = data['results'];
        }
        return specialtyList.map((json) => Specialty.fromJson(json)).toList();
      } else {
        throw 'Không thể tải danh sách chuyên khoa.';
      }
    } catch (e) {
      print('Lỗi khi tải chuyên khoa: $e');
      rethrow;
    }
  }

  
  // 2. CREATE
  Future<Specialty> createSpecialty(String name) async {
    try {
      final response = await _dio.post('/specialties/', data: {'name': name});
      return Specialty.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['name']?.first ?? 'Không thể tạo chuyên khoa.';
    }
  }

  // 3. UPDATE (Hàm mới)
  Future<Specialty> updateSpecialty(int id, String name) async {
    try {
      final response = await _dio.put('/specialties/$id/', data: {'name': name});
      return Specialty.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['name']?.first ?? 'Không thể cập nhật chuyên khoa.';
    }
  }

  // 4. DELETE (Hàm mới)
  Future<void> deleteSpecialty(int id) async {
    try {
      await _dio.delete('/specialties/$id/');
    } catch (e) {
      throw 'Không thể xóa chuyên khoa. Có thể nó đang được sử dụng.';
    }
  }
}