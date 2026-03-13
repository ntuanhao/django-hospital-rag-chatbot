// lib/screens/doctor/doctor_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/models/appointment.dart';
import 'package:hospital_app/providers/appointments_provider.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart'; 

// class DoctorAppointmentsScreen extends ConsumerWidget {
//   const DoctorAppointmentsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Sử dụng provider mới dành cho bác sĩ
//     final appointmentsState = ref.watch(doctorAppointmentsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lịch hẹn của Bác sĩ'),
//       ),
//       body: appointmentsState.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Lỗi tải danh sách: $err')),
//         data: (appointments) {
//           // Lọc ra các lịch hẹn đã được xác nhận và sắp tới
//           final upcomingConfirmed = appointments.where((a) => 
//               a.status == 'CONFIRMED' && a.appointmentTime.isAfter(DateTime.now())
//           ).toList();

//           // Sắp xếp theo thời gian sớm nhất
//           upcomingConfirmed.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

//           if (upcomingConfirmed.isEmpty) {
//             return const Center(child: Text('Không có lịch hẹn nào sắp tới.'));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(8.0),
//             itemCount: upcomingConfirmed.length,
//             itemBuilder: (context, index) {
//               final appointment = upcomingConfirmed[index];
//               return Card(
//                 elevation: 3,
//                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                   leading: CircleAvatar(
//                     child: Text(
//                       appointment.patient.fullName.isNotEmpty 
//                           ? appointment.patient.fullName[0].toUpperCase() 
//                           : 'P'
//                     ),
//                   ),
//                   title: Text(
//                     appointment.patient.fullName,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     'Ngày: ${DateFormat.yMd('vi_VN').format(appointment.appointmentTime)}\n'
//                     'Lý do: ${appointment.reason}',
//                   ),
//                   trailing: Text(
//                     DateFormat.Hm('vi_VN').format(appointment.appointmentTime),
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   onTap: () {
//                     // context.push(
//                     //   '/doctor/schedule/appointments/${appointment.patient.id}?patientName=${appointment.patient.fullName}'
//                     // );
//                     context.push('/doctor/schedule/appointments/start-encounter', extra: appointment);
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class DoctorAppointmentsScreen extends ConsumerWidget {
  const DoctorAppointmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(doctorAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn Chờ khám'), // Đổi tên cho rõ ràng hơn
      ),
      body: appointmentsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải danh sách: $err')),
        data: (appointments) {
          // <<< SỬA LẠI HOÀN TOÀN LOGIC LỌC Ở ĐÂY >>>
          // Lấy các lịch hẹn đã Check-in hoặc đã Xác nhận (sắp tới)
          final waitingList = appointments.where((a) {
            // Bao gồm cả 2 trạng thái quan trọng
            final bool isWaiting = a.status == 'CONFIRMED' || a.status == 'CHECKED_IN';
            // Vẫn kiểm tra xem nó có phải là lịch hẹn trong tương lai không
            final bool isUpcoming = a.appointmentTime.isAfter(DateTime.now().subtract(const Duration(hours: 3))); // Cho phép xem cả các lịch hẹn vừa qua 3 tiếng
            return isWaiting && isUpcoming;
          }).toList();

          // Sắp xếp để các lịch hẹn CHECKED_IN luôn ở trên cùng
          waitingList.sort((a, b) {
            if (a.status == 'CHECKED_IN' && b.status != 'CHECKED_IN') return -1;
            if (a.status != 'CHECKED_IN' && b.status == 'CHECKED_IN') return 1;
            return a.appointmentTime.compareTo(b.appointmentTime);
          });

          if (waitingList.isEmpty) {
            return const Center(child: Text('Không có bệnh nhân nào đang chờ khám.'));
          }

          // Sử dụng danh sách đã lọc mới
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: waitingList.length,
            itemBuilder: (context, index) {
              final appointment = waitingList[index];
              return Card(
                elevation: 3,
                color: appointment.status == 'CHECKED_IN' ? Colors.lightGreen[50] : Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  // leading: CircleAvatar(
                  //   child: Text(appointment.patient.fullName.isNotEmpty ? appointment.patient.fullName[0].toUpperCase() : 'P'),
                  // ),
                  leading: CircleAvatar(
                    backgroundImage: appointment.patient.avatarUrl != null
                      ? NetworkImage(appointment.patient.avatarUrl!)
                      : null,
                    child: appointment.patient.avatarUrl == null
                      ? Text(appointment.patient.fullName.isNotEmpty ? appointment.patient.fullName[0].toUpperCase() : 'P')
                      : null,
                  ),
                  title: Text(
                    appointment.patient.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Ngày: ${DateFormat.yMd('vi_VN').format(appointment.appointmentTime)}\n'
                            'Lý do: ${appointment.reason}'),
                  isThreeLine: true,
                  trailing: Text(
                    DateFormat.Hm('vi_VN').format(appointment.appointmentTime),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onTap: () {
                    // Chỉ cho phép bắt đầu khám nếu đã check-in
                    if (appointment.status == 'CHECKED_IN') {
                       context.push('/doctor/schedule/appointments/start-encounter', extra: appointment);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bệnh nhân cần được Lễ tân Check-in trước.'))
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}