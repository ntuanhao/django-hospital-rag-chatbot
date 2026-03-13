// lib/services/global_search_service.dart

import 'package:hospital_app/models/global_search_result.dart';
import 'package:hospital_app/models/service.dart';
import 'package:hospital_app/models/specialty.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/services/dio_client.dart';

class GlobalSearchService {
  final _dio = DioClient().dio;

  Future<GlobalSearchResult> search(String query) async {
    try {
      final response = await _dio.get('/search/', queryParameters: {'q': query});
      final data = response.data as Map<String, dynamic>;
      
      // Parse dữ liệu từ JSON thành các object Dart
      final doctors = (data['doctors'] as List? ?? []).map((d) => UserAccount.fromJson(d)).toList();
      final services = (data['services'] as List? ?? []).map((s) => Service.fromJson(s)).toList();
      final specialties = (data['specialties'] as List? ?? []).map((sp) => Specialty.fromJson(sp)).toList();

      return GlobalSearchResult(
        doctors: doctors,
        services: services,
        specialties: specialties,
      );
    } catch (e) {
      rethrow;
    }
  }
}