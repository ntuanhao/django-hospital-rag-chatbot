// lib/screens/booking/select_service_for_doctor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/doctor_provider.dart';

class SelectServiceForDoctorScreen extends ConsumerWidget {
  final int doctorId;
  // const SelectServiceForDoctorScreen({required this.doctorId, Key? key}) : super(key: key);
  final int? patientId; 

  const SelectServiceForDoctorScreen({
    required this.doctorId,
    this.patientId, // <<< THÊM VÀO CONSTRUCTOR >>>
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesForDoctorProvider(doctorId));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Dịch vụ')),
      body: servicesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,s) => Center(child: Text('Lỗi: $e')),
        data: (services) {
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(service.name),
                onTap: () {
                  // ĐÃ CÓ doctorId và đã chọn được service
                  // Bây giờ đi đến màn hình đặt lịch
                  context.push('/patient/home/search-doctor/$doctorId/book');
                },
              );
            },
          );
        },
      ),
    );
  }
}