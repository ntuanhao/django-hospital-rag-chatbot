
// lib/screens/receptionist/receptionist_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/models/appointment.dart';
import 'package:hospital_app/providers/appointments_provider.dart';
import 'package:intl/intl.dart';

class ReceptionistAppointmentsScreen extends ConsumerWidget {
  const ReceptionistAppointmentsScreen({Key? key}) : super(key: key);

  // Hàm helper mới để xử lý hành động và hiển thị thông báo
  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      // Có thể thêm loading indicator ở đây nếu muốn
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Hàm helper để hiển thị Dialog Từ chối
  void _showRejectDialog(BuildContext context, WidgetRef ref, int appointmentId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Từ chối lịch hẹn'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Nhập lý do từ chối',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập lý do.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop();
                _handleAction(
                  context,
                  ref,
                  () => ref.read(receptionistAppointmentsProvider.notifier).rejectAppointment(appointmentId, reasonController.text.trim()),
                  'Từ chối lịch hẹn thành công!',
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(receptionistAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Lịch hẹn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại danh sách',
            onPressed: () {
              ref.invalidate(receptionistAppointmentsProvider);
            },
          ),
        ],
      ),
      body: appointmentsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải danh sách: $err')),
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(child: Text('Không có lịch hẹn nào trong hệ thống.'));
          }

          appointments.sort((a, b) {
            int statusValue(String status) {
              switch (status) {
                case 'PATIENT_REQUESTED': return 1;
                case 'CONFIRMED': return 2;
                case 'CHECKED_IN': return 3;
                default: return 4;
              }
            }
            if (statusValue(a.status) < statusValue(b.status)) return -1;
            if (statusValue(a.status) > statusValue(b.status)) return 1;
            return a.appointmentTime.compareTo(b.appointmentTime);
          });
          
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              
              Widget trailingAction;
              switch (appointment.status) {
                case 'PATIENT_REQUESTED':
                  trailingAction = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () => _showRejectDialog(context, ref, appointment.id),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Từ chối'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _handleAction(
                          context, ref,
                          () => ref.read(receptionistAppointmentsProvider.notifier).confirmAppointment(appointment.id),
                          'Xác nhận lịch hẹn thành công!',
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  );
                  break;
                case 'CONFIRMED':
                  trailingAction = ElevatedButton(
                    onPressed: () => _handleAction(
                      context, ref,
                      () => ref.read(receptionistAppointmentsProvider.notifier).checkInAppointment(appointment.id),
                      'Check-in thành công!',
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Check-in'),
                  );
                  break;
                case 'CHECKED_IN':
                  trailingAction = ElevatedButton(
                    onPressed: () => _handleAction(
                      context, ref,
                      () => ref.read(receptionistAppointmentsProvider.notifier).completeAppointment(appointment.id),
                      'Đánh dấu hoàn thành thành công!',
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: const Text('Hoàn thành'),
                  );
                  break;
                default:
                  trailingAction = Chip(
                    label: Text(_translateStatus(appointment.status)),
                    backgroundColor: _getStatusColor(appointment.status),
                  );
                  break;
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: _getCardColor(appointment.status),
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: _getCardBorder(appointment.status),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // <<< THAY ĐỔI CHÍNH NẰM Ở ĐÂY >>>
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // -- AVATAR BỆNH NHÂN --
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: appointment.patient.avatarUrl != null
                                    ? NetworkImage(appointment.patient.avatarUrl!)
                                    : null,
                                child: appointment.patient.avatarUrl == null
                                    ? Text(
                                        appointment.patient.fullName.isNotEmpty ? appointment.patient.fullName[0].toUpperCase() : '?',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text('BN', style: Theme.of(context).textTheme.bodySmall)
                            ],
                          ),
                          const SizedBox(width: 12),
                          // -- THÔNG TIN CHÍNH --
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appointment.patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('BS: ${appointment.doctor.fullName}'),
                                Text('Thời gian: ${DateFormat.yMd('vi_VN').add_Hm().format(appointment.appointmentTime)}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: trailingAction,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'CONFIRMED': return 'Đã xác nhận';
      case 'PATIENT_REQUESTED': return 'Chờ xử lý';
      case 'COMPLETED': return 'Hoàn thành';
      case 'CANCELLED': return 'Đã hủy';
      case 'REJECTED': return 'Đã từ chối';
      case 'CHECKED_IN': return 'Đã check-in';
      case 'RECEPTIONIST_PROPOSED': return 'Đã đề xuất';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED': return Colors.green.shade100;
      case 'COMPLETED': return Colors.blue.shade100;
      case 'CANCELLED': return Colors.grey.shade300;
      case 'REJECTED': return Colors.red.shade100;
      case 'CHECKED_IN': return Colors.purple.shade100;
      default: return Colors.grey.shade200;
    }
  }

  Color? _getCardColor(String status) {
    switch (status) {
      case 'PATIENT_REQUESTED': return Colors.orange[50];
      case 'CONFIRMED': return Colors.blue[50];
      case 'CHECKED_IN': return Colors.purple[50];
      default: return Colors.white;
    }
  }

  BorderSide _getCardBorder(String status) {
     switch (status) {
      case 'PATIENT_REQUESTED': return BorderSide(color: Colors.orange.shade200, width: 1);
      case 'CONFIRMED': return BorderSide(color: Colors.blue.shade200, width: 1);
      case 'CHECKED_IN': return BorderSide(color: Colors.purple.shade200, width: 1);
      default: return BorderSide.none;
    }
  }
}