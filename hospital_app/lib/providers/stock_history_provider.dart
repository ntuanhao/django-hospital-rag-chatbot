// lib/providers/stock_history_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/stock_transaction.dart';
// <<< IMPORT SERVICE TỪ FILE RIÊNG >>>
import 'package:hospital_app/services/stock_history_service.dart';

// 1. Provider cho Service (đúng kiến trúc)
final stockHistoryServiceProvider = Provider((ref) => StockHistoryService());

// 2. Provider để fetch và cung cấp dữ liệu
final stockHistoryProvider = FutureProvider.autoDispose<List<StockTransaction>>((ref) {
  // Watch provider service và gọi hàm từ đó
  return ref.watch(stockHistoryServiceProvider).getStockHistory();
});