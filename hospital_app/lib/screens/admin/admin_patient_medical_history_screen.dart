// lib/screens/admin/admin_patient_medical_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/patient_provider.dart'; // Sử dụng provider đã có
import 'package:intl/intl.dart';

class AdminPatientMedicalHistoryScreen extends ConsumerWidget {
  final UserAccount patient;
  const AdminPatientMedicalHistoryScreen({required this.patient, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gọi provider để lấy lịch sử khám của bệnh nhân này
    final encountersAsync = ref.watch(patientEncountersProvider(patient.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Bệnh án của ${patient.fullName}'),
      ),
      body: encountersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Lỗi: $err')),
        data: (encounters) {
          if (encounters.isEmpty) {
            return const Center(child: Text('Bệnh nhân này chưa có lịch sử khám bệnh.'));
          }
          return ListView.builder(
            itemCount: encounters.length,
            itemBuilder: (context, index) {
              final encounter = encounters[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text('Ngày khám: ${DateFormat('dd/MM/yyyy HH:mm').format(encounter.appointmentTime.toLocal())}'),
                  subtitle: Text('Chẩn đoán: ${encounter.diagnosis}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Điều hướng đến màn hình chi tiết bệnh án mà bệnh nhân vẫn xem
                    context.push('/patient/home/medical-results/detail', extra: encounter);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}