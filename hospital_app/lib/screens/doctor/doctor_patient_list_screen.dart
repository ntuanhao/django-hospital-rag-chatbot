// lib/screens/doctor/doctor_patient_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/providers/doctor_provider.dart';
import 'package:go_router/go_router.dart';

class DoctorPatientListScreen extends ConsumerWidget {
  const DoctorPatientListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsState = ref.watch(myPatientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách Bệnh nhân')),
      body: patientsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (patients) {
          if (patients.isEmpty) {
            return const Center(child: Text('Bạn chưa có bệnh nhân nào.'));
          }
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: patient.avatar != null ? NetworkImage(patient.avatar!) : null,
                  child: patient.avatar == null ? Text(patient.firstName.isNotEmpty ? patient.firstName[0] : '?') : null,
                ),
                title: Text('${patient.lastName} ${patient.firstName}'),
                subtitle: Text(patient.phoneNumber ?? 'Chưa có SĐT'),
                onTap: () {
      // Điều hướng đến màn hình xem bệnh án, truyền ID và Tên bệnh nhân
                  final fullName = Uri.encodeComponent('${patient.lastName} ${patient.firstName}');
                  context.push('/doctor/schedule/my-patients/${patient.id}/record?patientName=$fullName');
                },
              );
            },
          );
        },
      ),
    );
  }
}
