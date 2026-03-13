// // lib/screens/appointments/appointments_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/models/appointment.dart';
// import 'package:hospital_app/providers/appointments_provider.dart';
// import 'package:intl/intl.dart';


// class AppointmentsScreen extends ConsumerWidget {
//   const AppointmentsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appointmentsState = ref.watch(patientAppointmentsProvider);

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Lịch Hẹn Của Tôi'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(icon: Icon(Icons.update), text: 'SẮP TỚI'),
//               Tab(icon: Icon(Icons.history), text: 'LỊCH SỬ'),
//             ],
//           ),
//         ),
//         body: appointmentsState.when(
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (err, stack) => Center(child: Text('Lỗi tải danh sách: $err')),
//           data: (appointments) {
//             final upcoming = appointments.where((a) => a.status != 'COMPLETED' && a.status != 'CANCELLED').toList();
//             final history = appointments.where((a) => a.status == 'COMPLETED' || a.status == 'CANCELLED').toList();
//             upcoming.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
//             history.sort((a, b) => b.appointmentTime.compareTo(a.appointmentTime));

//             return TabBarView(
//               children: [
//                 _buildAppointmentList(upcoming, 'Bạn không có lịch hẹn nào sắp tới.', context, ref),
//                 _buildAppointmentList(history, 'Lịch sử khám của bạn trống.', context, ref),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildAppointmentList(
//       List<Appointment> appointments, String emptyMessage, BuildContext context, WidgetRef ref) {
//     if (appointments.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)),
//         ),
//       );
//     }
    
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: appointments.length,
//       itemBuilder: (context, index) {
//         final appointment = appointments[index];
//         // Điều kiện để hiển thị nút hủy
//         final bool canCancel = appointment.status == 'PATIENT_REQUESTED';

//         return Card(
//           elevation: 3,
//           margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   title: Text(
//                     'Khám với BS. ${appointment.doctor.fullName}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     '${DateFormat.Hm('vi_VN').format(appointment.appointmentTime)} - ${DateFormat.yMd('vi_VN').format(appointment.appointmentTime)}\n'
//                     'Lý do: ${appointment.reason}'
//                   ),
//                   trailing: Chip(
//                     label: Text(
//                       _translateStatus(appointment.status),
//                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
//                     ),
//                     backgroundColor: _getStatusColor(appointment.status),
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   ),
//                   isThreeLine: true,
//                 ),
//                 // Chỉ hiển thị hàng chứa nút bấm nếu có thể hủy
//                 if (canCancel)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           _showCancelConfirmationDialog(context, ref, appointment.id);
//                         },
//                         style: TextButton.styleFrom(foregroundColor: Colors.red),
//                         child: const Text('Hủy Lịch'),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // <<< THÊM MỚI: Hàm hiển thị Dialog xác nhận hủy >>>
//   void _showCancelConfirmationDialog(BuildContext context, WidgetRef ref, int appointmentId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Xác nhận hủy'),
//           content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này không?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Không'),
//               onPressed: () => Navigator.of(dialogContext).pop(),
//             ),
//             TextButton(
//               child: const Text('Có, Hủy'),
//               style: TextButton.styleFrom(foregroundColor: Colors.red),
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop(); // Đóng dialog trước
//                 // Gọi hành động hủy từ provider
//                 final success = await ref
//                     .read(patientAppointmentsProvider.notifier)
//                     .cancelAppointment(appointmentId);
                
//                 // Hiển thị thông báo kết quả
//                 if (context.mounted) {
//                    ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(success ? 'Hủy lịch hẹn thành công!' : 'Hủy lịch hẹn thất bại.'),
//                       backgroundColor: success ? Colors.green : Colors.red,
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Hàm helper để lấy màu cho từng trạng thái
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'CONFIRMED': return Colors.green.shade200;
//       case 'PATIENT_REQUESTED': return Colors.orange.shade200;
//       case 'COMPLETED': return Colors.blue.shade200;
//       case 'CANCELLED': return Colors.grey.shade300;
//       default: return Colors.grey.shade200;
//     }
//   }

//   // Hàm helper để dịch trạng thái sang tiếng Việt
//   String _translateStatus(String status) {
//     switch (status) {
//       case 'CONFIRMED': return 'Đã xác nhận';
//       case 'PATIENT_REQUESTED': return 'Chờ xác nhận';
//       case 'COMPLETED': return 'Hoàn thành';
//       case 'CANCELLED': return 'Đã hủy';
//       case 'RECEPTIONIST_PROPOSED': return 'Chờ bạn XN';
//       default: return status;
//     }
//   }
// }
// lib/screens/appointments/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/appointment.dart';
import 'package:hospital_app/providers/appointments_provider.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  // Hàm helper chung để xử lý hành động và hiển thị thông báo
  Future<void> _handleAction(
    BuildContext context,
    Future<bool> Function() action,
    String successMessage,
    String failureMessage,
  ) async {
    final success = await action();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? successMessage : failureMessage),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // Hàm hiển thị dialog xác nhận HỦY/TỪ CHỐI
  void _showCancelConfirmationDialog(BuildContext context, WidgetRef ref, int appointmentId, bool isRejecting) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isRejecting ? 'Xác nhận Từ chối' : 'Xác nhận Hủy'),
        content: Text('Bạn có chắc chắn muốn ${isRejecting ? 'từ chối' : 'hủy'} lịch hẹn này không?'),
        actions: [
          TextButton(
            child: const Text('Không'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: Text(isRejecting ? 'Có, Từ chối' : 'Có, Hủy'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleAction(
                context,
                () => ref.read(patientAppointmentsProvider.notifier).cancelAppointment(appointmentId),
                '${isRejecting ? 'Từ chối' : 'Hủy'} lịch hẹn thành công!',
                '${isRejecting ? 'Từ chối' : 'Hủy'} lịch hẹn thất bại.',
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(patientAppointmentsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch Hẹn Của Tôi'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.update), text: 'SẮP TỚI'),
              Tab(icon: Icon(Icons.history), text: 'LỊCH SỬ'),
            ],
          ),
        ),
        body: appointmentsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi: $err')),
          data: (appointments) {
            final upcoming = appointments.where((a) => a.status != 'COMPLETED' && a.status != 'CANCELLED').toList();
            final history = appointments.where((a) => a.status == 'COMPLETED' || a.status == 'CANCELLED').toList();
            upcoming.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
            history.sort((a, b) => b.appointmentTime.compareTo(a.appointmentTime));

            return TabBarView(
              children: [
                _buildAppointmentList(upcoming, 'Bạn không có lịch hẹn nào sắp tới.', context, ref),
                _buildAppointmentList(history, 'Lịch sử khám của bạn trống.', context, ref),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments, String emptyMessage, BuildContext context, WidgetRef ref) {
    if (appointments.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        
        final bool canConfirmOrCancel = appointment.status == 'RECEPTIONIST_PROPOSED';
        final bool canCancelOnly = appointment.status == 'PATIENT_REQUESTED';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Khám với BS. ${appointment.doctor.fullName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${DateFormat.Hm('vi_VN').format(appointment.appointmentTime)} - ${DateFormat.yMd('vi_VN').format(appointment.appointmentTime)}\n'
                    'Lý do: ${appointment.reason}'
                  ),
                  trailing: Chip(
                    label: Text(_translateStatus(appointment.status), style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: _getStatusColor(appointment.status),
                  ),
                  isThreeLine: true,
                ),
                if (canConfirmOrCancel || canCancelOnly)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                           _showCancelConfirmationDialog(context, ref, appointment.id, canConfirmOrCancel);
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(canConfirmOrCancel ? 'Từ chối' : 'Hủy'),
                      ),
                      const SizedBox(width: 8),
                      if (canConfirmOrCancel)
                        ElevatedButton(
                          onPressed: () {
                            _handleAction(
                              context,
                              () => ref.read(patientAppointmentsProvider.notifier).patientConfirmAppointment(appointment.id),
                              'Xác nhận lịch hẹn thành công!',
                              'Xác nhận lịch hẹn thất bại.',
                            );
                          },
                          child: const Text('Xác nhận'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'CONFIRMED': return 'Đã xác nhận';
      case 'PATIENT_REQUESTED': return 'Chờ xác nhận';
      case 'COMPLETED': return 'Hoàn thành';
      case 'CANCELLED': return 'Đã hủy';
      case 'REJECTED': return 'Đã từ chối';
      case 'CHECKED_IN': return 'Đã check-in';
      case 'RECEPTIONIST_PROPOSED': return 'Chờ bạn XN';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED': return Colors.green.shade100;
      case 'RECEPTIONIST_PROPOSED': return Colors.orange.shade100;
      case 'PATIENT_REQUESTED': return Colors.yellow.shade100;
      case 'COMPLETED': return Colors.blue.shade100;
      case 'CANCELLED': return Colors.grey.shade300;
      case 'REJECTED': return Colors.red.shade100;
      case 'CHECKED_IN': return Colors.purple.shade100;
      default: return Colors.grey.shade200;
    }
  }
}