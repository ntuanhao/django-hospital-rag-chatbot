// lib/models/global_search_result.dart

import 'package:hospital_app/models/service.dart';
import 'package:hospital_app/models/specialty.dart';
import 'package:hospital_app/models/user_account.dart';

class GlobalSearchResult {
  final List<UserAccount> doctors;
  final List<Service> services;
  final List<Specialty> specialties;

  GlobalSearchResult({
    required this.doctors,
    required this.services,
    required this.specialties,
  });
}