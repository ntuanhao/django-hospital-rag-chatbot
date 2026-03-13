// lib/providers/stock_voucher_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/stock_voucher.dart';
import 'package:hospital_app/services/stock_voucher_service.dart';

// Provider cho Service
final stockVoucherServiceProvider = Provider.autoDispose((ref) => StockVoucherService());

// Provider để lấy danh sách các phiếu kho
final stockVoucherListProvider = 
    AsyncNotifierProvider<StockVoucherListNotifier, List<StockVoucher>>(
        StockVoucherListNotifier.new);

class StockVoucherListNotifier extends AsyncNotifier<List<StockVoucher>> {
  @override
  FutureOr<List<StockVoucher>> build() {
    return ref.watch(stockVoucherServiceProvider).getVouchers();
  }

  // Hàm để làm mới danh sách
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(stockVoucherServiceProvider).getVouchers());
  }
}


// Provider để quản lý hành động tạo phiếu mới
final createVoucherProvider = 
    AsyncNotifierProvider<CreateVoucherNotifier, void>(
        CreateVoucherNotifier.new);

class CreateVoucherNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Không cần làm gì ở đây
  }

  Future<bool> createVoucher({
    required String voucherType,
    required String reason,
    required List<Map<String, dynamic>> transactions,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(stockVoucherServiceProvider).createVoucher(
        voucherType: voucherType,
        reason: reason,
        transactions: transactions,
      );
    });

    // Trả về true nếu thành công, false nếu có lỗi
    return !state.hasError;
  }
}