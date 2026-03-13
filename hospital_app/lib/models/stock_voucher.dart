// lib/models/stock_voucher.dart

class StockVoucher {
  final int id;
  final String voucherTypeDisplay; // "Phiếu Nhập kho" hoặc "Phiếu Xuất kho"
  final String reason;
  final String? createdByUsername;
  final DateTime createdAt;

  StockVoucher({
    required this.id,
    required this.voucherTypeDisplay,
    required this.reason,
    this.createdByUsername,
    required this.createdAt,
  });

  factory StockVoucher.fromJson(Map<String, dynamic> json) {
    return StockVoucher(
      id: json['id'],
      voucherTypeDisplay: json['voucher_type_display'],
      reason: json['reason'],
      createdByUsername: json['created_by_username'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}