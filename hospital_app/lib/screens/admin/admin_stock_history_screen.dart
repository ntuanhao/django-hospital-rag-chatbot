// lib/screens/admin/admin_stock_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/stock_transaction.dart';
import 'package:hospital_app/providers/stock_history_provider.dart';
import 'package:intl/intl.dart';

class AdminStockHistoryScreen extends ConsumerWidget {
  const AdminStockHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(stockHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử Kho'),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('Chưa có giao dịch nào.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(stockHistoryProvider.future),
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _TransactionCard(transaction: transactions[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final StockTransaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isStockIn = transaction.quantity > 0;
    final color = isStockIn ? Colors.green : (transaction.transactionTypeDisplay == 'Xuất kho' ? Colors.orange : Colors.red);
    final icon = isStockIn ? Icons.arrow_upward : Icons.arrow_downward;
    final quantityText = (isStockIn ? '+' : '') + transaction.quantity.toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.medicineName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  quantityText,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow(Icons.category_outlined, transaction.transactionTypeDisplay, color),
            if(transaction.notes != null && transaction.notes!.isNotEmpty)
               _buildInfoRow(Icons.notes_outlined, transaction.notes!, Colors.grey.shade700),
            _buildInfoRow(Icons.person_outline, 'Thực hiện: ${transaction.createdByUser ?? 'Hệ thống'}', Colors.grey.shade700),
            _buildInfoRow(Icons.schedule, DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt.toLocal()), Colors.grey.shade700),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}