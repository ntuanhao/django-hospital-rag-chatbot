// lib/screens/booking/service_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/service_provider.dart';

// import provider và model của service (cần tạo)

class ServiceListScreen extends ConsumerWidget {
  final int specialtyId;
  final int? patientId; 
  const ServiceListScreen({required this.specialtyId, this.patientId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gọi provider .family để lấy service theo specialtyId
    final servicesState = ref.watch(serviceListProvider(specialtyId));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Dịch vụ')),
      body: servicesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Lỗi: $e')),
        data: (services) {
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(service.name),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // ĐÃ CÓ specialtyId, giờ đi đến màn hình chọn BÁC SĨ
                  // context.push('/patient/home/doctors-by-specialty/${specialtyId}');
                  context.push('/patient/home/doctors-by-specialty/${specialtyId}?serviceId=${service.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}