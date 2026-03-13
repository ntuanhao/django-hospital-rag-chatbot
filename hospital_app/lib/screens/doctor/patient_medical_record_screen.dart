// lib/screens/doctor/patient_medical_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/providers/patient_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PatientMedicalRecordScreen extends ConsumerWidget {
  final int patientId;
  final String patientName;

  const PatientMedicalRecordScreen({
    required this.patientId,
    required this.patientName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy lịch sử khám của bệnh nhân
    final encountersState = ref.watch(patientEncountersProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Bệnh án: $patientName'),
      ),
      body: encountersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (encounters) {
          if (encounters.isEmpty) {
            return const Center(child: Text('Bệnh nhân chưa có lịch sử khám.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: encounters.length,
            itemBuilder: (context, index) {
              final encounter = encounters[index];
              // TODO: Xây dựng widget hiển thị chi tiết một lần khám
              // return Card(
              //   margin: const EdgeInsets.symmetric(vertical: 8),
              //   child: ListTile(
              //     title: Text('Chẩn đoán: ${encounter.diagnosis}'),
              //     subtitle: Text('Triệu chứng: ${encounter.symptoms}'),
              //   ),
              // );
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Khám ngày: ${DateFormat.yMd('vi_VN').format(encounter.appointmentTime)}'),
                  subtitle: Text('Chẩn đoán: ${encounter.diagnosis}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    // <<< CẬP NHẬT onTAP Ở ĐÂY >>>
                    onTap: () {
                    context.push(
    '/doctor/schedule/my-patients/${encounter.patientId}/record/detail', // patientId cần được thêm vào model Encounter
    extra: encounter
  );
                    // final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
                    // context.push('$currentPath/detail', extra: encounter);
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