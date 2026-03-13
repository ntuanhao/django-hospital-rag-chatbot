// lib/providers/admin_monitoring_provider.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/appointment.dart';
// <<< IMPORT SERVICE TỪ FILE RIÊNG >>>
import 'package:hospital_app/services/admin_monitoring_service.dart';

// 1. Lớp chứa các bộ lọc (không đổi)
class AppointmentFilter extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? doctorId;
  final String? status;

  const AppointmentFilter({this.startDate, this.endDate, this.doctorId, this.status});
  
  @override
  List<Object?> get props => [startDate, endDate, doctorId, status];
}

// 2. Provider cho Service (đúng kiến trúc)
final adminMonitoringServiceProvider = Provider((ref) => AdminMonitoringService());

// 3. Provider chính để fetch và cung cấp dữ liệu
final adminAppointmentsProvider = 
  FutureProvider.autoDispose.family<List<Appointment>, AppointmentFilter>((ref, filter) {
    // Watch provider service và gọi hàm từ đó
    return ref.watch(adminMonitoringServiceProvider).getFilteredAppointments(filter);
});