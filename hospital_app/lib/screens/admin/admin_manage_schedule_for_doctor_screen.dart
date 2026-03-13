import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/doctor_provider.dart';

class AdminManageScheduleForDoctorScreen extends ConsumerWidget {
  final UserAccount doctor;
  const AdminManageScheduleForDoctorScreen({required this.doctor, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(adminGetDoctorScheduleProvider(doctor.id));

    // <<< THÊM MỚI: LẮNG NGHE TRẠNG THÁI CỦA PROVIDER HÀNH ĐỘNG >>>
    // Để hiển thị SnackBar khi có lỗi từ hành động thêm/xóa
    ref.listen<AsyncValue<void>>(adminScheduleActionsProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch làm việc của BS. ${doctor.firstName}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(context, ref, doctor.id),
        tooltip: 'Thêm ca làm việc',
        child: const Icon(Icons.add),
      ),
      body: schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Lỗi: $err')),
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('Bác sĩ này chưa có lịch làm việc.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(adminGetDoctorScheduleProvider(doctor.id).future),
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return ListTile(
                  title: Text(schedule.dayOfWeekDisplay),
                  subtitle: Text('Từ ${schedule.startTime.substring(0,5)} đến ${schedule.endTime.substring(0,5)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      // <<< CẬP NHẬT HÀM XÓA >>>
                      // Hiển thị dialog xác nhận trước khi xóa
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: Text('Bạn có chắc muốn xóa ca làm việc này không?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xóa')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(adminScheduleActionsProvider.notifier).removeSchedule(
                          doctorId: doctor.id, 
                          scheduleId: schedule.id,
                        );
                        // Hiển thị thông báo thành công
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã xóa ca làm việc thành công.'), backgroundColor: Colors.green),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref, int doctorId) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AddScheduleDialog(doctorId: doctorId),
    );
  }
}

// ============== DIALOG THÊM LỊCH LÀM VIỆC ==============
class _AddScheduleDialog extends ConsumerStatefulWidget {
  final int doctorId;
  const _AddScheduleDialog({required this.doctorId});

  @override
  ConsumerState<_AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends ConsumerState<_AddScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _weekdays = [
    'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'
  ];

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) _startTime = pickedTime;
        else _endTime = pickedTime;
      });
    }
  }

  // <<< CẬP NHẬT HÀM SUBMIT >>>
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(adminScheduleActionsProvider.notifier).addSchedule(
        doctorId: widget.doctorId,
        dayOfWeek: _selectedDay!,
        startTime: _startTime!,
        endTime: _endTime!,
      );
      
      // Kiểm tra trạng thái của provider hành động sau khi chạy
      // provider.state sẽ là AsyncData nếu thành công, AsyncError nếu thất bại
      final state = ref.read(adminScheduleActionsProvider); 
      if (!state.hasError && mounted) {
        // Đóng dialog
        Navigator.of(context).pop();
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm ca làm việc thành công.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminScheduleActionsProvider);

    return AlertDialog(
      title: const Text('Thêm ca làm việc mới'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(labelText: 'Chọn ngày trong tuần'),
              items: _weekdays.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value;
                });
              },
              validator: (value) => value == null ? 'Vui lòng chọn ngày' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Giờ bắt đầu'),
                      child: Text(_startTime?.format(context) ?? 'Chọn giờ'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Giờ kết thúc'),
                      child: Text(_endTime?.format(context) ?? 'Chọn giờ'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: state.isLoading ? null : _submit,
          child: state.isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Thêm'),
        ),
      ],
    );
  }
}