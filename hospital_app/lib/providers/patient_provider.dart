
// lib/providers/patient_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/encounter.dart';
import 'package:hospital_app/models/user_account.dart'; // <<< THÊM IMPORT NÀY
import 'package:hospital_app/services/patient_service.dart';

// Provider cho service (không thay đổi)
final patientServiceProvider = Provider<PatientService>((ref) => PatientService());

// Provider để Bệnh nhân xem lịch sử khám của chính mình (không thay đổi)
final myEncountersProvider = FutureProvider.autoDispose<List<Encounter>>((ref) {
  return ref.watch(patientServiceProvider).getMyEncounters();
});

// Provider để Bác sĩ/Lễ tân xem lịch sử khám của một bệnh nhân cụ thể (không thay đổi)
final patientEncountersProvider = 
  FutureProvider.autoDispose.family<List<Encounter>, int>((ref, patientId) {
    final patientService = ref.watch(patientServiceProvider);
    return patientService.getPatientEncounters(patientId);
});

// <<< NÂNG CẤP PROVIDER NÀY THÀNH .family >>>
// Provider này để Lễ tân lấy và tìm kiếm danh sách tất cả bệnh nhân
final patientListProvider = 
  FutureProvider.autoDispose.family<List<UserAccount>, String>((ref, searchQuery) async {
    // searchQuery là chuỗi người dùng gõ vào ô tìm kiếm
    final patientService = ref.watch(patientServiceProvider);
    return patientService.getAllPatients(searchQuery: searchQuery);
});
