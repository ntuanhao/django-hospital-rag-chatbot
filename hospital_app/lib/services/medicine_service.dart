// lib/services/medicine_service.dart
import 'package:dio/dio.dart';
import 'package:hospital_app/models/medicine.dart';
import 'package:hospital_app/services/dio_client.dart';

class MedicineService {
  final Dio _dio = DioClient().dio;
  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      final response = await _dio.get('/medicines/', queryParameters: {'search': query});
      List<dynamic> data = response.data as List;
      return data.map((json) => Medicine.fromJson(json)).toList();
    } catch (e) { rethrow; }
  }

  Future<Medicine> createMedicine({
    required String name,
    required String unit,
    String? description,
    int initialStock = 0,
  }) async {
    try {
      final response = await _dio.post('/medicines/', data: {
        'name': name,
        'unit': unit,
        'description': description,
        'stock_quantity': initialStock,
      });
      return Medicine.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data.toString() ?? 'Không thể tạo thuốc mới.';
    }
  }

  // UPDATE
  Future<Medicine> updateMedicine({
    required int id,
    required String name,
    required String unit,
    String? description,
  }) async {
    try {
      // Lưu ý: Không cho sửa stock_quantity trực tiếp ở đây
      final response = await _dio.put('/medicines/$id/', data: {
        'name': name,
        'unit': unit,
        'description': description,
      });
      return Medicine.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data.toString() ?? 'Không thể cập nhật thuốc.';
    }
  }

  // DELETE
  Future<void> deleteMedicine(int id) async {
    try {
      await _dio.delete('/medicines/$id/');
    } catch (e) {
      throw 'Không thể xóa thuốc. Có thể nó đã được kê đơn.';
    }
  }

  //  HÀM XUẤT KHO 
  Future<Medicine> removeStock({
    required int id,
    required int quantity,
    required String notes,
  }) async {
    try {
      final response = await _dio.post(
        '/medicines/$id/remove_stock/',
        data: {'quantity': quantity, 'notes': notes},
      );
      return Medicine.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Không thể xuất kho.';
    }
  }
  
  // HÀM NHẬP KHO 
  // Future<Medicine> addStock(int id, int quantity) async {
  //   try {
  //     final response = await _dio.post(
  //       '/medicines/$id/add_stock/',
  //       data: {'quantity': quantity},
  //     );
  //     return Medicine.fromJson(response.data);
  //   } on DioException catch (e) {
  //     throw e.response?.data['error'] ?? 'Không thể nhập kho.';
  //   }
  // }
  Future<Medicine> addStock(int id, int quantity, {String? notes}) async {
    try {
      final response = await _dio.post(
        '/medicines/$id/add_stock/',
        data: {'quantity': quantity, 'notes': notes},
      );
      return Medicine.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Không thể nhập kho.';
    }
  }
  
}