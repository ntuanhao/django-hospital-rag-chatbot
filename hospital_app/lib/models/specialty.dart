// lib/models/specialty.dart
class Specialty {
  final int id;
  final String name;

  Specialty({
    required this.id,
    required this.name,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}