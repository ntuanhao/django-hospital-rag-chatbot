// // lib/models/service.dart
// class Service {
//   final int id;
//   final String name;
//   final String price; // Backend là DecimalField, nhận về dưới dạng String là an toàn nhất

//   Service({
//     required this.id,
//     required this.name,
//     required this.price,
//   });

//   factory Service.fromJson(Map<String, dynamic> json) {
//     return Service(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       price: json['price'] as String,
//     );
//   }
// }
// lib/models/service.dart

class Service {
  final int id;
  final String name;
  final String price;
  // <<< THÊM DÒNG NÀY VÀO >>>
  final List<int> specialtyIds; 

  Service({
    required this.id,
    required this.name,
    required this.price,
    // <<< THÊM DÒNG NÀY VÀO >>>
    required this.specialtyIds,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      price: json['price'].toString(),
      // <<< THÊM DÒNG NÀY VÀO >>>
      // Nó sẽ đọc danh sách ID từ key 'specialties' của JSON
      specialtyIds: List<int>.from(json['specialties'] ?? []),
    );
  }
}