// lib/providers/appointments_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/services/appointment_service.dart';// chỉnh path nếu khác
import 'package:hospital_app/models/appointment.dart';




//xác nhận, từ chối, check in, hoàn thành lịch hẹn của lễ tân
final receptionistAppointmentsProvider = 
          AsyncNotifierProvider.autoDispose<ReceptionistAppointmentsNotifier, List<Appointment>>(
        ReceptionistAppointmentsNotifier.new,
);

class ReceptionistAppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    // Tái sử dụng service và hàm get
    return ref.read(appointmentServiceProvider).getMyAppointments();
  }

  
  Future<void> confirmAppointment(int appointmentId) async {
    final service = ref.read(appointmentServiceProvider);
    // Không bắt lỗi, để nó tự nổi lên
    await service.confirmAppointment(appointmentId);
    // Nếu không có lỗi, làm mới lại danh sách
    ref.invalidateSelf();
  }

  Future<void> rejectAppointment(int appointmentId, String reason) async {
    final service = ref.read(appointmentServiceProvider);
    await service.rejectAppointment(appointmentId, reason);
    ref.invalidateSelf();
  }
  
  Future<void> checkInAppointment(int appointmentId) async {
    final service = ref.read(appointmentServiceProvider);
    await service.checkInAppointment(appointmentId);
   ref.invalidateSelf();
  }

  Future<void> completeAppointment(int appointmentId) async {
    final service = ref.read(appointmentServiceProvider);
    await service.completeAppointment(appointmentId);
    ref.invalidateSelf();
  }

}





final doctorAppointmentsProvider = 
    AsyncNotifierProvider.autoDispose<DoctorAppointmentsNotifier, List<Appointment>>(
        DoctorAppointmentsNotifier.new);

class DoctorAppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    return ref.read(appointmentServiceProvider).getMyAppointments();
  }

  // Bác sĩ cũng có quyền hoàn thành cuộc hẹn
  Future<void> completeAppointment(int appointmentId) async {
    final service = ref.read(appointmentServiceProvider);
    // Để lỗi tự nổi lên
    await service.completeAppointment(appointmentId);
    // Tự làm mới
    ref.invalidateSelf();
  }
}

//Các chức năng lịch hẹn của bệnh nhân
final patientAppointmentsProvider =
    AsyncNotifierProvider.autoDispose<PatientAppointmentsNotifier, List<Appointment>>(
  PatientAppointmentsNotifier.new,
);
class PatientAppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  FutureOr<List<Appointment>> build() async {
    final appointmentService = ref.read(appointmentServiceProvider);
    return appointmentService.getMyAppointments();
  }


  // <<< THÊM MỚI: Hành động hủy lịch hẹn >>>
  Future<bool> cancelAppointment(int appointmentId) async {
    final appointmentService = ref.read(appointmentServiceProvider);
    
    try {
      await appointmentService.cancelAppointment(appointmentId);
      // Nếu hủy thành công, làm mới lại provider để nó tự fetch lại dữ liệu
      ref.invalidateSelf();
      return true; // Trả về true để báo cho UI biết đã thành công
    } catch (e) {
      print("Lỗi khi hủy lịch hẹn: $e");
      return false; // Trả về false để báo cho UI biết đã thất bại
    }
  }

  Future<bool> patientConfirmAppointment(int appointmentId) async {
    final service = ref.read(appointmentServiceProvider);
    try {
      await service.patientConfirmAppointment(appointmentId);
      ref.invalidateSelf(); // Tải lại danh sách
      return true;
    } catch (e) {
      print("Lỗi khi bệnh nhân xác nhận: $e");
      return false;
    }
  }
  
}



// Provider quản lý hành động đặt lịch (Giữ nguyên, đã đúng)
final appointmentBookingProvider =
    AsyncNotifierProvider.autoDispose<AppointmentBookingNotifier, void>(
  AppointmentBookingNotifier.new,
);


class AppointmentBookingNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // state mặc định AsyncData(null)
  }

  Future<void> createAppointment({
    required int doctorId,
    required DateTime appointmentDate,
    required TimeOfDay appointmentTime,
    required String reason,
    int? patientId,
    int? serviceId,
    List<int>? serviceIds,
  }) async {
    final appointmentService = ref.read(appointmentServiceProvider);

    final fullAppointmentTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      appointmentTime.hour,
      appointmentTime.minute,
    ); // Mặc định đây là local time
    

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await appointmentService.createAppointment(
        doctorId: doctorId,
        appointmentTime: fullAppointmentTime,
        reason: reason,
        patientId: patientId,
        serviceIds: serviceIds,
        
      );
    });

    // Nếu muốn reload danh sách sau khi tạo
    if (!state.hasError) {
      ref.invalidate(patientAppointmentsProvider); // <<< Sửa lại tên provider
    }
  }

  void reset() {
    state = const AsyncData(null);
  }

  

}


