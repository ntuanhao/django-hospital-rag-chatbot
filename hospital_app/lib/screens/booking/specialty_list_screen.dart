// lib/screens/booking/specialty_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/specialty_provider.dart';

class SpecialtyListScreen extends ConsumerWidget {
  const SpecialtyListScreen({Key? key}) : super(key: key);
  // final int? patientId; // Thêm tham số
  // const SpecialtyListScreen({this.patientId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialtiesState = ref.watch(specialtyListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Chuyên khoa')),
      body: specialtiesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Lỗi tải chuyên khoa: $e')),
        data: (specialties) {
          return ListView.separated(
            itemCount: specialties.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final specialty = specialties[index];
              return ListTile(
                title: Text(specialty.name, style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Điều hướng đến màn hình chọn bác sĩ, truyền specialty.id
                  // context.push('/patient/home/search-doctors-by-specialty/${specialty.id}');
                  context.push('/patient/home/doctors-by-specialty/${specialty.id}');
                  // context.push('/patient/home/select-service/${specialty.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}