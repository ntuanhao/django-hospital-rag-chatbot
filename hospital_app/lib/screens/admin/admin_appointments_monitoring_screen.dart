// lib/screens/admin/admin_appointments_monitoring_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/providers/admin_monitoring_provider.dart';
import 'package:intl/intl.dart';

class AdminAppointmentsMonitoringScreen extends ConsumerStatefulWidget {
  const AdminAppointmentsMonitoringScreen({super.key});

  @override
  ConsumerState<AdminAppointmentsMonitoringScreen> createState() => _AdminAppointmentsMonitoringScreenState();
}

class _AdminAppointmentsMonitoringScreenState extends ConsumerState<AdminAppointmentsMonitoringScreen> {
  // State để lưu các giá trị filter
  DateTimeRange? _selectedDateRange;
  // TODO: Thêm state cho doctorId và status

  // Hàm để hiển thị Date Range Picker
  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tạo đối tượng filter từ state
    final filter = AppointmentFilter(
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
    );
    final appointmentsAsync = ref.watch(adminAppointmentsProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giám sát Lịch hẹn'),
      ),
      body: Column(
        children: [
          // Khu vực Filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: const Icon(Icons.date_range),
                    label: Text(_selectedDateRange == null 
                        ? 'Chọn khoảng ngày' 
                        : '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                    ),
                  ),
                ),
                if (_selectedDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _selectedDateRange = null),
                  ),
              ],
            ),
          ),
          // TODO: Thêm UI cho các bộ lọc khác (Bác sĩ, Trạng thái)

          // Danh sách kết quả
          Expanded(
            child: appointmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Lỗi: $err')),
              data: (appointments) {
                if (appointments.isEmpty) {
                  return const Center(child: Text('Không có lịch hẹn nào khớp.'));
                }
                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final app = appointments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('BN: ${app.patient.fullName}'),
                        subtitle: Text('BS: ${app.doctor.fullName}\n${DateFormat('dd/MM/yyyy HH:mm').format(app.appointmentTime.toLocal())}'),
                        trailing: Chip(label: Text(app.status)),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}