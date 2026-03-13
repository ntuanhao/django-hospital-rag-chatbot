import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/models/recurring_schedule.dart';
import 'package:hospital_app/providers/appointments_provider.dart';
import 'package:hospital_app/providers/doctor_provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hospital_app/models/service.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  final int doctorId;
  final int? patientId;
  final int? serviceId;
  
  const AppointmentBookingScreen({required this.doctorId,this.patientId, this.serviceId, Key? key}) : super(key: key);

  @override
  ConsumerState<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends ConsumerState<AppointmentBookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTimeSlot;
  final _reasonController = TextEditingController();
  
  final List<Service> _selectedServices = [];
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Hàm helper để tạo danh sách các khung giờ
  List<TimeOfDay> _generateTimeSlots(List<RecurringSchedule> schedules) {
    if (_selectedDay == null) return [];
    final int selectedWeekday = _selectedDay!.weekday - 1;
    final List<TimeOfDay> slots = [];
    final workingSlots = schedules.where((s) => s.dayOfWeek == selectedWeekday);
    for (var slot in workingSlots) {
      TimeOfDay parseTime(String timeStr) {
          final parts = timeStr.split(':');
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      TimeOfDay currentTime = parseTime(slot.startTime);
      final TimeOfDay endTime = parseTime(slot.endTime);
      while (currentTime.hour < endTime.hour || (currentTime.hour == endTime.hour && currentTime.minute < endTime.minute)) {
        slots.add(currentTime);
        final newTimeInMinutes = currentTime.hour * 60 + currentTime.minute + 30;
        currentTime = TimeOfDay(hour: newTimeInMinutes ~/ 60, minute: newTimeInMinutes % 60);
      }
    }
    return slots;
  }

  // Hàm helper để kiểm tra ngày làm việc
  bool isDayAvailable(DateTime day, List<RecurringSchedule> schedules) {
    final int dayOfWeek = day.weekday - 1;
    return schedules.any((schedule) => schedule.dayOfWeek == dayOfWeek);
  }

  void _showServiceSelectionDialog(List<Service> availableServices) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Tái sử dụng dialog đã có
        return _ServiceSelectionDialog(
          availableServices: availableServices,
          initialSelectedServices: _selectedServices,
          onSelectionChanged: (selected) {
            setState(() {
              _selectedServices.clear();
              _selectedServices.addAll(selected);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái của quá trình booking
    ref.listen<AsyncValue<void>>(appointmentBookingProvider, (previous, next) {
      if (next is AsyncError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' ${next.error.toString()}'), backgroundColor: Colors.red),
        );
      }
      if (next is AsyncData && previous is AsyncLoading && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lịch hẹn thành công!'), backgroundColor: Colors.green),
        );
        context.go('/patient/home');
      }
    });

    final scheduleState = ref.watch(doctorScheduleProvider(widget.doctorId));
    final bookingState = ref.watch(appointmentBookingProvider);
    final isBooking = bookingState is AsyncLoading;

    final servicesForDoctorAsync = ref.watch(servicesForDoctorProvider(widget.doctorId));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Ngày & Giờ Khám')),
      body: scheduleState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải lịch làm việc: $err')),
        data: (schedules) {
          final timeSlots = _generateTimeSlots(schedules);
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // --- PHẦN LỊCH ---
              Card(
                elevation: 2,
                child: TableCalendar(
                  locale: 'vi_VN',
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 60)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (isDayAvailable(selectedDay, schedules)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedTimeSlot = null;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bác sĩ không làm việc vào ngày này.'))
                      );
                    }
                  },
                  enabledDayPredicate: (day) {
                    if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) return false;
                    return isDayAvailable(day, schedules);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // --- PHẦN KHUNG GIỜ ---
              if (_selectedDay != null) ...[
                Text('Chọn giờ khám cho ngày ${DateFormat.yMd('vi_VN').format(_selectedDay!)}', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (timeSlots.isEmpty) 
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Không có khung giờ trống cho ngày này.', style: TextStyle(fontStyle: FontStyle.italic)),
                  )
                else
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: timeSlots.map((slot) {
                      final isSelected = _selectedTimeSlot == slot;
                       return ChoiceChip(
      label: Text(slot.format(context)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTimeSlot = selected ? slot : null;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.green : Colors.grey,
        ),
      ),
    );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
              ],
              
              // --- PHẦN LÝ DO KHÁM VÀ NÚT BẤM ---
              if (_selectedTimeSlot != null) ...[
                 Text('Thông tin thêm', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 TextField(
                   controller: _reasonController,
                   decoration: const InputDecoration(labelText: 'Nhập lý do khám (bắt buộc)', border: OutlineInputBorder(), hintText: 'Ví dụ: Tái khám, đau bụng...'),
                   maxLines: 3,
                 ),
                 const SizedBox(height: 16),
                 servicesForDoctorAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (err, st) => Text('Lỗi tải dịch vụ: $err', style: const TextStyle(color: Colors.red)),
                  data: (services) {
                    if (services.isEmpty) return const SizedBox.shrink();
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dịch vụ đăng ký (tùy chọn)', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (_selectedServices.isEmpty)
                              const Text('Chưa có dịch vụ nào được chọn.', style: TextStyle(fontStyle: FontStyle.italic)),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _selectedServices.map((service) => Chip(
                                label: Text(service.name),
                                onDeleted: () {
                                  setState(() => _selectedServices.remove(service));
                                }
                              )).toList(),
                            ),
                            Center(
                              child: TextButton.icon(
                                onPressed: () => _showServiceSelectionDialog(services),
                                icon: const Icon(Icons.add_circle_outline),
                                label: Text(_selectedServices.isEmpty ? 'Chọn dịch vụ' : 'Thêm/Sửa dịch vụ'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                 const SizedBox(height: 24),
                 ElevatedButton(
                   onPressed: isBooking ? null : () {
                     if (_reasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do khám.')));
                        return;
                     }
                     final serviceIds = _selectedServices.map((s) => s.id).toList();

                     ref.read(appointmentBookingProvider.notifier).createAppointment(
                        doctorId: widget.doctorId,
                        serviceIds: serviceIds,
                        patientId: widget.patientId,
                        appointmentDate: _selectedDay!,
                        appointmentTime: _selectedTimeSlot!,
                        reason: _reasonController.text.trim());
                        
                        
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.green, foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                   ),
                   child: isBooking
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('XÁC NHẬN ĐẶT LỊCH'),
                 )
              ]
            ],
          );
        },
      ),
    );
  }
}

class _ServiceSelectionDialog extends StatefulWidget {
  final List<Service> availableServices;
  final List<Service> initialSelectedServices;
  final ValueChanged<List<Service>> onSelectionChanged;

  const _ServiceSelectionDialog({
    required this.availableServices,
    required this.initialSelectedServices,
    required this.onSelectionChanged,
  });

  @override
  State<_ServiceSelectionDialog> createState() => _ServiceSelectionDialogState();
}

class _ServiceSelectionDialogState extends State<_ServiceSelectionDialog> {
  late final Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelectedServices.map((s) => s.id).toSet();
  }

  void _onConfirm() {
    final selectedServices = widget.availableServices
        .where((s) => _selectedIds.contains(s.id))
        .toList();
    widget.onSelectionChanged(selectedServices);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn dịch vụ'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.availableServices.isEmpty
          ? const Text('Bác sĩ này chưa có dịch vụ nào.')
          : ListView.builder(
              shrinkWrap: true,
              itemCount: widget.availableServices.length,
              itemBuilder: (context, index) {
                final service = widget.availableServices[index];
                final isSelected = _selectedIds.contains(service.id);
                return CheckboxListTile(
                  title: Text(service.name),
                  subtitle: Text('Giá: ${NumberFormat.decimalPattern('vi_VN').format(int.tryParse(service.price) ?? 0)} VNĐ'),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(service.id);
                      } else {
                        _selectedIds.remove(service.id);
                      }
                    });
                  },
                );
              },
            ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        ElevatedButton(onPressed: _onConfirm, child: const Text('Xác nhận')),
      ],
    );
  }
}