// lib/screens/patient/medical_results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/providers/patient_provider.dart';
import 'package:go_router/go_router.dart';

class MedicalResultsScreen extends ConsumerWidget {
  const MedicalResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encountersState = ref.watch(myEncountersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kết Quả Khám Bệnh')),
      body: encountersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (encounters) {
          if (encounters.isEmpty) {
            return const Center(child: Text('Bạn chưa có kết quả khám nào.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: encounters.length,
            itemBuilder: (context, index) {
              final encounter = encounters[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Khám với BS. ${encounter.doctorName}'),
                  subtitle: Text('Chẩn đoán: ${encounter.diagnosis}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
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