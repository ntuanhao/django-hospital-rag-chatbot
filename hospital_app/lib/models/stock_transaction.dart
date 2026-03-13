// lib/models/stock_transaction.dart
class StockTransaction {
  final int id;
  final String medicineName;
  final String transactionTypeDisplay;
  final int quantity;
  final String? notes;
  final String? createdByUser;
  final DateTime createdAt;

  StockTransaction({
    required this.id,
    required this.medicineName,
    required this.transactionTypeDisplay,
    required this.quantity,
    this.notes,
    this.createdByUser,
    required this.createdAt,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'],
      medicineName: json['medicine_name'],
      transactionTypeDisplay: json['transaction_type_display'],
      quantity: json['quantity'],
      notes: json['notes'],
      createdByUser: json['created_by_username'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}