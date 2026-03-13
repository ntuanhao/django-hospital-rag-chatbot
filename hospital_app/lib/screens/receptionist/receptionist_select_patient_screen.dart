// lib/screens/receptionist/receptionist_select_patient_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/widgets/patient_search_delegate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';


class ReceptionistSelectPatientScreen extends ConsumerWidget {
  const ReceptionistSelectPatientScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bước 1: Chọn Bệnh nhân')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('Tìm kiếm Bệnh nhân'),
          onPressed: () async {
            final selectedPatient = await showSearch<UserAccount?>(
              context: context,
              delegate: PatientSearchDelegate(ref),
            );
            
            if (selectedPatient != null && context.mounted) {
              // Sau khi chọn, đi đến màn hình lựa chọn (của Bệnh nhân)
              // và truyền patientId qua `extra`
              context.push('/patient/home/book-appointment', extra: selectedPatient.id);
            }
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      ),
    );
  }
}