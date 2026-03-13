// lib/screens/admin/admin_voucher_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/stock_voucher_provider.dart';
import 'package:intl/intl.dart';

class AdminVoucherListScreen extends ConsumerWidget {
  const AdminVoucherListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe provider để lấy danh sách các phiếu
    final vouchersAsync = ref.watch(stockVoucherListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Phiếu Kho'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Điều hướng đến trang tạo phiếu mới
          context.push('/admin/dashboard/vouchers/create');
        },
        label: const Text('Tạo Phiếu'),
        icon: const Icon(Icons.add),
      ),
      body: vouchersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi tải dữ liệu: $error')),
        data: (vouchers) {
          if (vouchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có phiếu kho nào được tạo.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(stockVoucherListProvider),
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate để provider fetch lại dữ liệu
              ref.invalidate(stockVoucherListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Chừa không gian cho FAB
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                final isStockIn = voucher.voucherTypeDisplay == 'Phiếu Nhập kho';
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (isStockIn ? Colors.green : Colors.orange).withOpacity(0.1),
                      child: Icon(
                        isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isStockIn ? Colors.green : Colors.orange,
                      ),
                    ),
                    title: Text(
                      voucher.voucherTypeDisplay,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Lý do: ${voucher.reason}\n'
                      'Tạo bởi: ${voucher.createdByUsername ?? 'N/A'} - ${DateFormat('dd/MM/yyyy HH:mm').format(voucher.createdAt.toLocal())}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Điều hướng đến trang chi tiết phiếu kho
                      // context.push('/admin/dashboard/vouchers/${voucher.id}');
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Chức năng xem chi tiết phiếu sẽ được phát triển.'))
                       );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}