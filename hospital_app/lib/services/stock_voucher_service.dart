// lib/services/stock_voucher_service.dart

import 'package:hospital_app/models/stock_voucher.dart';
import 'package:hospital_app/services/dio_client.dart';

class StockVoucherService {
  final _dio = DioClient().dio;

  // Lấy danh sách tất cả các phiếu
  Future<List<StockVoucher>> getVouchers() async {
    try {
      final response = await _dio.get('/stock-vouchers/');
      final data = response.data as List;
      return data.map((json) => StockVoucher.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Tạo một phiếu mới
  Future<StockVoucher> createVoucher({
    required String voucherType, // 'STOCK_IN' or 'STOCK_OUT'
    required String reason,
    required List<Map<String, dynamic>> transactions,
  }) async {
    try {
      final response = await _dio.post('/stock-vouchers/', data: {
        'voucher_type': voucherType,
        'reason': reason,
        'transactions': transactions,
      });
      return StockVoucher.fromJson(response.data);
    } catch (e) {
      // Cố gắng throw lỗi từ server nếu có
      rethrow;
    }
  }

  // (Tùy chọn) Lấy chi tiết một phiếu (nếu cần sau này)
  Future<StockVoucher> getVoucherDetail(int id) async {
    try {
      final response = await _dio.get('/stock-vouchers/$id/');
      return StockVoucher.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}