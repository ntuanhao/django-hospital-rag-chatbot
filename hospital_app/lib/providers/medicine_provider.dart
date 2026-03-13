// lib/providers/medicine_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/medicine.dart';
import 'package:hospital_app/services/medicine_service.dart';

final medicineServiceProvider = Provider((ref) => MedicineService());

final medicineSearchProvider = 
  FutureProvider.autoDispose.family<List<Medicine>, String>((ref, query) {
    return ref.watch(medicineServiceProvider).searchMedicines(query);
});

final adminMedicineListProvider = 
    AsyncNotifierProvider.autoDispose<AdminMedicineListNotifier, List<Medicine>>(
        AdminMedicineListNotifier.new);

class AdminMedicineListNotifier extends AsyncNotifier<List<Medicine>> {
  
  @override
  FutureOr<List<Medicine>> build() {
    // Lấy tất cả thuốc bằng cách tìm kiếm với query rỗng
    return ref.watch(medicineServiceProvider).searchMedicines('');
  }

  Future<void> addMedicine({
    required String name,
    required String unit,
    String? description,
    int initialStock = 0,
  }) async {
    final service = ref.read(medicineServiceProvider);
    await AsyncValue.guard(() => service.createMedicine(
      name: name, unit: unit, description: description, initialStock: initialStock
    ));
    ref.invalidateSelf();
  }

  Future<void> updateMedicine({
    required int id,
    required String name,
    required String unit,
    String? description,
  }) async {
    final service = ref.read(medicineServiceProvider);
    await AsyncValue.guard(() => service.updateMedicine(
      id: id, name: name, unit: unit, description: description
    ));
    ref.invalidateSelf();
  }

  Future<void> deleteMedicine(int id) async {
    final service = ref.read(medicineServiceProvider);
    await AsyncValue.guard(() => service.deleteMedicine(id));
    ref.invalidateSelf();
  }

  Future<void> addStock(int id, int quantity, {String? notes}) async {
    final service = ref.read(medicineServiceProvider);
    await AsyncValue.guard(() => service.addStock(id, quantity, notes: notes));
    ref.invalidateSelf();
  }

  Future<void> removeStock({
    required int id,
    required int quantity,
    required String notes,
  }) async {
    final service = ref.read(medicineServiceProvider);
    await AsyncValue.guard(() => service.removeStock(id: id, quantity: quantity, notes: notes));
    ref.invalidateSelf();
  }
}