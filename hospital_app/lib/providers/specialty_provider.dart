// // lib/providers/specialty_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/models/specialty.dart';
// import 'package:hospital_app/services/specialty_service.dart';

// // Provider cho service
// final specialtyServiceProvider = Provider.autoDispose((ref) => SpecialtyService());

// // FutureProvider để lấy và cung cấp danh sách chuyên khoa
// final specialtyListProvider = FutureProvider.autoDispose<List<Specialty>>((ref) {
//   final specialtyService = ref.watch(specialtyServiceProvider);
//   return specialtyService.getSpecialties();
// });


// lib/providers/specialty_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/specialty.dart';
import 'package:hospital_app/services/specialty_service.dart';

// Provider cho service (không thay đổi)
final specialtyServiceProvider = Provider.autoDispose((ref) => SpecialtyService());

// <<< NÂNG CẤP THÀNH ASYCNOTIFIERPROVIDER >>>
final specialtyListProvider = 
    AsyncNotifierProvider.autoDispose<SpecialtyListNotifier, List<Specialty>>(
        SpecialtyListNotifier.new);

class SpecialtyListNotifier extends AsyncNotifier<List<Specialty>> {
  
  // build() sẽ fetch dữ liệu ban đầu
  @override
  FutureOr<List<Specialty>> build() {
    return ref.watch(specialtyServiceProvider).getSpecialties();
  }

  // Hành động THÊM chuyên khoa
  Future<void> addSpecialty(String name) async {
    final specialtyService = ref.read(specialtyServiceProvider);
    // Không cần đặt state về loading, để UI tự xử lý
    // Dùng guard để bắt lỗi từ service
    await AsyncValue.guard(() async {
      await specialtyService.createSpecialty(name);
    });
    // Làm mới lại provider để fetch lại danh sách mới nhất
    ref.invalidateSelf();
  }

  // Hành động SỬA chuyên khoa
  Future<void> updateSpecialty(int id, String newName) async {
    final specialtyService = ref.read(specialtyServiceProvider);
    await AsyncValue.guard(() async {
      await specialtyService.updateSpecialty(id, newName);
    });
    ref.invalidateSelf();
  }

  // Hành động XÓA chuyên khoa
  Future<void> deleteSpecialty(int id) async {
    final specialtyService = ref.read(specialtyServiceProvider);
    await AsyncValue.guard(() async {
      await specialtyService.deleteSpecialty(id);
    });
    ref.invalidateSelf();
  }
}