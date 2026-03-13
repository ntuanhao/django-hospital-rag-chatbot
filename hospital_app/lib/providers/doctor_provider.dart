// lib/providers/doctor_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/services/doctor_service.dart';
import 'package:hospital_app/models/recurring_schedule.dart';
import 'package:hospital_app/models/service.dart';
import 'package:flutter/material.dart';

import 'dart:async';

final doctorServiceProvider = Provider<DoctorService>((ref) => DoctorService());

// final doctorListProvider = FutureProvider.autoDispose<List<UserAccount>>((ref) {
//   final doctorService = ref.watch(doctorServiceProvider);
//   return doctorService.getDoctors();
// });

// <<< CẬP NHẬT KIỂU DỮ LIỆU CỦA PROVIDER NÀY >>>
final doctorScheduleProvider = 
  FutureProvider.autoDispose.family<List<RecurringSchedule>, int>((ref, doctorId) async {
    final doctorService = ref.watch(doctorServiceProvider);
    return doctorService.getDoctorSchedule(doctorId);
});

final myRecurringScheduleProvider = FutureProvider.autoDispose<List<RecurringSchedule>>((ref) {
  return ref.watch(doctorServiceProvider).getMyRecurringSchedule();
});

final myPatientsProvider = FutureProvider.autoDispose<List<UserAccount>>((ref) {
  return ref.watch(doctorServiceProvider).getMyPatients();
});


// final doctorListProvider = 
//   FutureProvider.autoDispose.family<List<UserAccount>, String>((ref, searchQuery) async {
//     final doctorService = ref.watch(doctorServiceProvider);
//     // Truyền searchQuery xuống cho service
//     return doctorService.getDoctors(searchQuery: searchQuery);
// });

// final doctorsBySpecialtyProvider = 
//   FutureProvider.autoDispose.family<List<UserAccount>, int>((ref, specialtyId) {
//     final doctorService = ref.watch(doctorServiceProvider);
//     return doctorService.getDoctors(specialtyId: specialtyId);
// });

typedef DoctorFilter = ({String searchQuery, int? specialtyId});

// Provider family duy nhất, nhận vào một record filter
final doctorListProvider = 
  FutureProvider.autoDispose.family<List<UserAccount>, DoctorFilter>((ref, filter) {
    final doctorService = ref.watch(doctorServiceProvider);
    // Truyền các giá trị từ record filter xuống service
    return doctorService.getDoctors(
      searchQuery: filter.searchQuery, 
      specialtyId: filter.specialtyId,
    );
});

final servicesForDoctorProvider = 
  FutureProvider.autoDispose.family<List<Service>, int>((ref, doctorId) {
    return ref.watch(doctorServiceProvider).getServicesForDoctor(doctorId);
});


//Admin

final adminGetDoctorScheduleProvider =
    FutureProvider.autoDispose.family<List<RecurringSchedule>, int>((ref, doctorId) {
  return ref.watch(doctorServiceProvider).getDoctorSchedule(doctorId);
});
final adminScheduleActionsProvider =
    AsyncNotifierProvider<AdminScheduleActionsNotifier, void>( // <<< SỬA LỖI 2
  AdminScheduleActionsNotifier.new,
);

// 2. Notifier để xử lý hành động (ĐÃ SỬA LỖI)
class AdminScheduleActionsNotifier extends AsyncNotifier<void> { // <<< SỬA LỖI 2: Chỉ cần <void>
  @override
  FutureOr<void> build() {
    // Không cần trả về gì ở đây, mặc định là trạng thái không hoạt động
  }

  Future<void> addSchedule({
    required int doctorId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    state = const AsyncLoading();
    // <<< SỬA LỖI 1: Gán lại state bằng kết quả của guard >>>
    state = await AsyncValue.guard(() async {
      await ref.read(doctorServiceProvider).createSchedule(
            doctorId: doctorId,
            dayOfWeek: dayOfWeek,
            startTime: startTime,
            endTime: endTime,
          );
    });
    if (!state.hasError) {
      ref.invalidate(adminGetDoctorScheduleProvider(doctorId));
    }
  }

  Future<void> removeSchedule({
    required int doctorId,
    required int scheduleId,
  }) async {
    state = const AsyncLoading();
    // <<< SỬA LỖI 1: Gán lại state bằng kết quả của guard >>>
    state = await AsyncValue.guard(() async {
      await ref.read(doctorServiceProvider).deleteSchedule(scheduleId);
    });
    if (!state.hasError) {
      ref.invalidate(adminGetDoctorScheduleProvider(doctorId));
    }
  }
}



