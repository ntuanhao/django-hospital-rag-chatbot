// lib/providers/stock_history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/stock_transaction.dart';
import 'package:hospital_app/services/dio_client.dart';

// 1. Service
class StockHistoryService {
  final _dio = DioClient().dio;

  Future<List<StockTransaction>> getStockHistory() async {
    try {
      final response = await _dio.get('/stock-transactions/');
      final data = response.data as List;
      return data.map((json) => StockTransaction.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

// 2. Provider cho Service
final stockHistoryServiceProvider = Provider((ref) => StockHistoryService());

// 3. Provider để fetch và cung cấp dữ liệu
final stockHistoryProvider = FutureProvider.autoDispose<List<StockTransaction>>((ref) {
  return ref.watch(stockHistoryServiceProvider).getStockHistory();
});