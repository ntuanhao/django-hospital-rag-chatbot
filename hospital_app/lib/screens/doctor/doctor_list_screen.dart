//  // lib/screens/doctor/doctor_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/providers/doctor_provider.dart';
// import 'package:hospital_app/models/user_account.dart';

// import 'package:go_router/go_router.dart';

// class DoctorListScreen extends ConsumerWidget {
//   final int? specialtyId;            // nếu đi từ màn hình Chọn chuyên khoa
//   final int? patientIdForBooking;    // nếu lễ tân đặt giúp bệnh nhân cụ thể

//   const DoctorListScreen({
//     Key? key,
//     this.specialtyId,
//     this.patientIdForBooking,
//   }) : super(key: key);



//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // QUAN TRỌNG: chỉ watch MỘT provider dựa trên specialtyId
//     final doctorsAsync = specialtyId != null
//         ? ref.watch(doctorsBySpecialtyProvider(specialtyId!))
//         : ref.watch(doctorListProvider('')); // danh sách tất cả bác sĩ

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chọn Bác sĩ'),
//         backgroundColor: Colors.green,
//       ),
//       body: doctorsAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Lỗi: $err')),
//         data: (List<UserAccount> doctors) {
//           if (doctors.isEmpty) {
//             return const Center(child: Text('Không có bác sĩ phù hợp'));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: doctors.length,
//             itemBuilder: (context, index) {
//               final doctor = doctors[index];

//               // final fullName = 'BS. ${doctor.firstName ?? ''} ${doctor.lastName ?? ''}'.trim();
//               final fullName = 'BS. ${doctor.firstName} ${doctor.lastName}'.trim();
//               final specialtyName = doctor.profile?.specialtyName ?? '';

//               final avatarUrl = doctor.avatar; // đổi theo field thật trong UserAccount

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   leading: CircleAvatar(
//                     radius: 28,
//                     backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
//                         ? NetworkImage(avatarUrl)
//                         : null,
//                     child: (avatarUrl == null || avatarUrl.isEmpty)
//                         ? const Icon(Icons.local_hospital)
//                         : null,
//                   ),
//                   title: Text(
//                     fullName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                   subtitle: Text(
//                     specialtyName,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () {
//                     // Nếu là lễ tân book thay bệnh nhân cụ thể
//                     // if (patientIdForBooking != null) {
//                     //   context.push(
//                     //     '/receptionist/dashboard/create-for-patient/${patientIdForBooking}/${doctor.id}',
//                     //   );
//                     // } else {
//                     //   // bệnh nhân tự chọn bác sĩ
//                     //   context.push(
//                     //     '/patient/home/select-doctor/${doctor.id}',
//                     //   );
//                     // }
//                     // Luồng của Lễ tân đặt hộ
//                     if (patientIdForBooking != null) {
//                       context.push('/receptionist/dashboard/create-for-patient/$patientIdForBooking/${doctor.id}');
//                     } 
//                     // Luồng của Bệnh nhân đi qua chuyên khoa
//                     else if (specialtyId != null) {
//                       context.push('/patient/home/doctors-by-specialty/$specialtyId/${doctor.id}');
//                     }
//                     // Luồng của Bệnh nhân tìm trực tiếp
//                     else {
//                       context.push('/patient/home/search-doctor/${doctor.id}');
//                     }
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/doctor_provider.dart';

// Chuyển thành ConsumerStatefulWidget để quản lý ô tìm kiếm
class DoctorListScreen extends ConsumerStatefulWidget {
  // Các tham số này vẫn giữ nguyên để xử lý các luồng khác nhau
  final int? specialtyId;
  final int? patientIdForBooking;
  final int? serviceId;

  const DoctorListScreen({
    this.specialtyId,
    this.patientIdForBooking,
    this.serviceId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Sử dụng debounce để tránh gọi API liên tục
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tạo record filter để truyền vào provider
    final filter = (searchQuery: _searchQuery, specialtyId: widget.specialtyId);
    final doctorsState = ref.watch(doctorListProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Bác sĩ'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // <<< THÊM Ô TÌM KIẾM Ở ĐÂY >>>
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bác sĩ theo tên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
          
          Expanded(
            child: doctorsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Lỗi: $error')),
              data: (doctors) {
                if (doctors.isEmpty) {
                  return Center(
                    child: Text(_searchQuery.isNotEmpty
                        ? 'Không tìm thấy bác sĩ nào khớp với "$_searchQuery".'
                        : 'Không có bác sĩ trong danh mục này.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    final profile = doctor.profile as DoctorProfile?;
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: doctor.avatar != null ? NetworkImage(doctor.avatar!) : null,
                          child: doctor.avatar == null ? const Icon(Icons.medical_services_outlined, size: 30, color: Colors.grey) : null,
                        ),
                        title: Text(
                          'BS. ${doctor.lastName} ${doctor.firstName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Chuyên khoa: ${profile?.specialtyName ?? 'Chung'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (widget.patientIdForBooking != null) {
                            context.push('/receptionist/dashboard/create-for-patient/${widget.patientIdForBooking}/${doctor.id}');
                          } else if (widget.specialtyId != null) {
                            context.push('/patient/home/doctors-by-specialty/${widget.specialtyId}/${doctor.id}');
                          } else {
                            // context.push('/patient/home/search-doctor/${doctor.id}');
                            context.push('/patient/home/search-doctor/${doctor.id}?serviceId=${widget.serviceId}');
                          }
                        },
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

