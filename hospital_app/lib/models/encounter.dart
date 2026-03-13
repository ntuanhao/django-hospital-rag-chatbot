
// import 'package:hospital_app/models/specialty.dart';
import 'package:hospital_app/models/service.dart';


class MedicineDetails {
  final int id;
  final String name;
  final String unit;

  MedicineDetails({required this.id, required this.name, required this.unit});

  factory MedicineDetails.fromJson(Map<String, dynamic> json) {
    return MedicineDetails(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Không rõ',
      unit: json['unit'] as String? ?? '',
    );
  }
}

class PrescriptionItem {
  final int id;
  final MedicineDetails medicineDetails;
  final String dosage;
  final int quantity;

  PrescriptionItem({
    required this.id,
    required this.medicineDetails,
    required this.dosage,
    required this.quantity,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      id: json['id'] as int? ?? 0,
      medicineDetails: json['medicine_details'] != null 
          ? MedicineDetails.fromJson(json['medicine_details'])
          : MedicineDetails(id: 0, name: 'Thuốc không xác định', unit: ''),
      dosage: json['dosage'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
    );
  }
}

class Prescription {
  final int id;
  final String? notes;
  final List<PrescriptionItem> items;

  Prescription({
    required this.id,
    this.notes,
    required this.items,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] is List ? json['items'] as List : [];
    final parsedItems = itemsList.map((i) => PrescriptionItem.fromJson(i)).toList();
    
    return Prescription(
      id: json['id'] as int? ?? 0,
      notes: json['notes'] as String?,
      items: parsedItems,
    );
  }
}

class Encounter {
  final int id;
  final int patientId;
  final String symptoms;
  final String diagnosis;
  final String patientName;
  final String doctorName;
  final DateTime appointmentTime;
  final List<Prescription> prescriptions;
  final String? specialtyName; 
  final String reasonWhy;
  final List<Service> servicesPerformed;

  Encounter({
    required this.id,
    required this.patientId,
    required this.symptoms,
    required this.diagnosis,
    required this.patientName,
    required this.doctorName,
    required this.appointmentTime,
    required this.prescriptions,
    this.specialtyName,
    required this.reasonWhy,
    required this.servicesPerformed,
    
  });

  factory Encounter.fromJson(Map<String, dynamic> json) {
    final prescriptionsList = json['prescriptions'] is List ? json['prescriptions'] as List : [];
    final parsedPrescriptions = prescriptionsList.map((p) => Prescription.fromJson(p)).toList();

    final servicesList = json['services_performed_details'] as List? ?? [];
    final parsedServices = servicesList.map((s) => Service.fromJson(s)).toList();

    return Encounter(
      id: json['id'] as int? ?? 0,
      patientId: json['patient_id'] as int? ?? 0,
      symptoms: json['symptoms'] as String? ?? 'Chưa cập nhật',
      diagnosis: json['diagnosis'] as String? ?? 'Chưa cập nhật',
      patientName: json['patient_name'] as String? ?? 'Không rõ',
      doctorName: json['doctor_name'] as String? ?? 'Không rõ',
      appointmentTime: DateTime.tryParse(json['appointment_time'] ?? '')?.toLocal() ?? DateTime.now(),
      reasonWhy: json['reason_why'] as String? ?? 'Không rõ',
      prescriptions: parsedPrescriptions,
      specialtyName: json['specialty_name'] as String?,
      servicesPerformed: parsedServices,
    );
  }
}