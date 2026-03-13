// lib/screens/doctor/doctor_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/providers/doctor_provider.dart';

class DoctorScheduleScreen extends ConsumerWidget {
  const DoctorScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(myRecurringScheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch Làm Việc Cố Định')),
      body: scheduleState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('Bạn chưa có lịch làm việc cố định nào.'));
          }
          // Sắp xếp theo thứ trong tuần
          schedules.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
          
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return Card(
                child: ListTile(
                  title: Text(
                    schedule.dayOfWeekDisplay,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Từ ${schedule.startTime} đến ${schedule.endTime}'
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Chức năng đề xuất thay đổi lịch (nâng cao)
        },
        child: const Icon(Icons.edit_calendar),
        tooltip: 'Đề xuất thay đổi',
      ),
    );
  }
}