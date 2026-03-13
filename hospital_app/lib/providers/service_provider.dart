// lib/providers/service_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/service.dart';
import 'package:hospital_app/services/service_service.dart';

// Provider cho service
final serviceServiceProvider = Provider.autoDispose((ref) => ServiceService());

// FutureProvider.family để lấy danh sách dịch vụ đã được lọc theo ID chuyên khoa
final serviceListProvider = 
  FutureProvider.autoDispose.family<List<Service>, int?>((ref, specialtyId) {
    final serviceService = ref.watch(serviceServiceProvider);
    return serviceService.getServices(specialtyId: specialtyId);
});


final adminServiceListProvider = 
    AsyncNotifierProvider.autoDispose<AdminServiceListNotifier, List<Service>>(
        AdminServiceListNotifier.new);

class AdminServiceListNotifier extends AsyncNotifier<List<Service>> {
  @override
  FutureOr<List<Service>> build() {
    // Gọi hàm getServices mà không cần specialtyId để lấy tất cả
    return ref.watch(serviceServiceProvider).getServices();
  }

  Future<void> addService({
    required String name,
    required String price,
    required List<int> specialtyIds,
  }) async {
    final service = ref.read(serviceServiceProvider);
    await AsyncValue.guard(() => service.createService(
      name: name, price: price, specialtyIds: specialtyIds
    ));
    ref.invalidateSelf();
  }

  Future<void> updateService({
    required int id,
    required String name,
    required String price,
    required List<int> specialtyIds,
  }) async {
    final service = ref.read(serviceServiceProvider);
    await AsyncValue.guard(() => service.updateService(
      id: id, name: name, price: price, specialtyIds: specialtyIds
    ));
    ref.invalidateSelf();
  }

  Future<void> deleteService(int id) async {
    final service = ref.read(serviceServiceProvider);
    await AsyncValue.guard(() => service.deleteService(id));
    ref.invalidateSelf();
  }
}

