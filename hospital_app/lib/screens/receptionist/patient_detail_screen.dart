import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/providers/patient_provider.dart';
import 'package:hospital_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class PatientDetailScreen extends ConsumerWidget {
  final int patientId;
  const PatientDetailScreen({required this.patientId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailState = ref.watch(userDetailProvider(patientId));
    final encountersState = ref.watch(patientEncountersProvider(patientId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Bệnh nhân')),
      body: userDetailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,s) => Center(child: Text('Lỗi tải thông tin: $e')),
        data: (user) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Thông tin cá nhân ---
              Text('Thông tin cá nhân', style: Theme.of(context).textTheme.titleLarge),
              ListTile(title: const Text('Họ tên'), subtitle: Text('${user.lastName} ${user.firstName}')),
              ListTile(title: const Text('Số điện thoại'), subtitle: Text(user.phoneNumber ?? 'N/A')),
              // ... thêm các thông tin khác từ `user` ...

              const Divider(height: 32),

              // --- Lịch sử khám ---
              Text('Lịch sử khám bệnh', style: Theme.of(context).textTheme.titleLarge),
              encountersState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Lỗi tải lịch sử khám: $e'),
                data: (encounters) {
                  if (encounters.isEmpty) return const Text('Chưa có lịch sử khám.');
                  return Column(
                    children: encounters.map((encounter) => Card(
                      child: ListTile(
                        title: Text('Khám ngày: ${DateFormat.yMd('vi_VN').format(encounter.appointmentTime)}'), // Cần thêm ngày vào Encounter model
                        subtitle: Text('Chẩn đoán: ${encounter.diagnosis}'),
                        onTap: () {
                          context.push('/receptionist/dashboard/manage-patients/$patientId/encounter-detail', extra: encounter);
                        },
                      ),
                    )).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
      // Nút hành động nhanh
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/receptionist/dashboard/create-for-patient/$patientId');
        },
        label: const Text('Tạo Lịch hẹn'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}