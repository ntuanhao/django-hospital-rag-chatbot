// lib/models/appointment.dart
import 'package:hospital_app/models/service.dart';

class UserSummary {
  final int id;
  final String username;
  final String fullName;
  final String? avatarUrl;

  UserSummary({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar'] as String?,
    );
  }
}

// Lớp chính để biểu diễn một lịch hẹn
class Appointment {
  final int id;
  final UserSummary patient;
  final UserSummary doctor;
  final DateTime appointmentTime;
  final String reason;
  final String status;
  final String? serviceName;
  final List<Service> services;

  Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.appointmentTime,
    required this.reason,
    required this.status,
    required this.serviceName,
    required this.services,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
  
  final servicesList = json['services_details'] as List? ?? [];
  final parsedServices = servicesList.map((s) => Service.fromJson(s)).toList();

    return Appointment(
      id: json['id'] as int,
      patient: UserSummary.fromJson(json['patient']),
      doctor: UserSummary.fromJson(json['doctor']),
      appointmentTime: DateTime.parse(json['appointment_time'] as String).toLocal(),
      reason: json['reason'] as String,
      status: json['status'] as String,
      serviceName: json['service_name'] as String?,
      services: parsedServices,
    );
  }
}