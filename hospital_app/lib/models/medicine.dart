// // lib/models/medicine.dart
// class Medicine {
//   final int id;
//   final String name;
//   final String unit;
//   final String description;
//   final int stockQuantity;
//   Medicine({required this.id, required this.name, required this.unit, required this.stockQuantity, required this.description});

//   factory Medicine.fromJson(Map<String, dynamic> json) {
//     return Medicine(id: json['id'], name: json['name'], unit: json['unit'],stockQuantity: json['stock_quantity'] as int? ?? 0, description: json['description'] as String);
//   }
// }

// lib/models/medicine.dart

class Medicine {
  final int id;
  final String name;
  final String unit;
  final String? description;
  final int stockQuantity;

  Medicine({
    required this.id,
    required this.name,
    required this.unit,
    this.description,
    required this.stockQuantity,
  });

  // <<< PHIÊN BẢN FACTORY AN TOÀN NHẤT >>>
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      // Dùng `?? 0` để đảm bảo id không bao giờ null
      id: json['id'] as int? ?? 0,
      
      // Dùng `??` để cung cấp giá trị mặc định an toàn cho String
      name: json['name'] as String? ?? 'Thuốc không tên',
      unit: json['unit'] as String? ?? 'N/A',
      
      // `description` vốn đã là nullable, nhưng vẫn ép kiểu an toàn
      description: json['description'] as String?,
      
      // Dùng `?? 0` để đảm bảo số lượng không bao giờ null
      stockQuantity: json['stock_quantity'] as int? ?? 0,
    );
  }
}