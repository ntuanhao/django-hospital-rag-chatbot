// // lib/screens/receptionist/receptionist_create_appointment_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/models/user_account.dart';
// import 'package:hospital_app/providers/doctor_provider.dart';
// import 'package:hospital_app/providers/patient_provider.dart';
// import 'package:go_router/go_router.dart';


// class ReceptionistCreateAppointmentScreen extends ConsumerWidget {
//   const ReceptionistCreateAppointmentScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final doctorsAsync = ref.watch(doctorListProvider);
//     final patientsAsync = ref.watch(patientListProvider);

//     UserAccount? selectedDoctor;
//     UserAccount? selectedPatient;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Tạo Lịch hẹn cho Bệnh nhân')),
//       body: doctorsAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => Center(child: Text('Lỗi tải danh sách bác sĩ: $e')),
//         data: (doctors) => patientsAsync.when(
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (e, s) => Center(child: Text('Lỗi tải danh sách bệnh nhân: $e')),
//           data: (patients) {
//             // Sử dụng StatefulWidget bên trong để quản lý state của Dropdown
//             return StatefulBuilder(
//               builder: (context, setState) {
//                 return ListView(
//                   padding: const EdgeInsets.all(16.0),
//                   children: [
//                     // Dropdown chọn bệnh nhân
//                     DropdownButtonFormField<UserAccount>(
//                       value: selectedPatient,
//                       hint: const Text('Chọn bệnh nhân'),
//                       items: patients.map((patient) => DropdownMenuItem(
//                         value: patient,
//                         child: Text(patient.lastName + ' ' + patient.firstName),
//                       )).toList(),
//                       onChanged: (value) => setState(() => selectedPatient = value),
//                       validator: (v) => v == null ? 'Vui lòng chọn bệnh nhân' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     // Dropdown chọn bác sĩ
//                     DropdownButtonFormField<UserAccount>(
//                       value: selectedDoctor,
//                       hint: const Text('Chọn bác sĩ'),
//                       items: doctors.map((doctor) => DropdownMenuItem(
//                         value: doctor,
//                         child: Text('BS. ' + doctor.lastName + ' ' + doctor.firstName),
//                       )).toList(),
//                       onChanged: (value) => setState(() => selectedDoctor = value),
//                        validator: (v) => v == null ? 'Vui lòng chọn bác sĩ' : null,
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton(
//                   onPressed: () {
                    
//                   },
//                   child: const Text('Tiếp tục'),
//                 )
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// lib/screens/receptionist/receptionist_create_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/doctor_provider.dart';
import 'package:hospital_app/providers/patient_provider.dart';
import 'package:go_router/go_router.dart';
// import 'package:hospital_app/widgets/user_search_field.dart';
import 'package:hospital_app/widgets/patient_search_delegate.dart';
import 'package:hospital_app/widgets/doctor_search_delegate.dart';
// <<< THAY ĐỔI 1: Chuyển sang ConsumerStatefulWidget >>>
class ReceptionistCreateAppointmentScreen extends ConsumerStatefulWidget {
  const ReceptionistCreateAppointmentScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReceptionistCreateAppointmentScreen> createState() =>
      _ReceptionistCreateAppointmentScreenState();
}

class _ReceptionistCreateAppointmentScreenState
    extends ConsumerState<ReceptionistCreateAppointmentScreen> {
  // <<< THAY ĐỔI 2: Quản lý state ở đây, không cần StatefulBuilder >>>
  UserAccount? _selectedDoctor;
  UserAccount? _selectedPatient;

  Future<void> _openPatientSearch(BuildContext context) async {
    // `showSearch` sẽ trả về kết quả khi màn hình tìm kiếm đóng lại
    final result = await showSearch<UserAccount?>(
      context: context,
      delegate: PatientSearchDelegate(ref),
    );

    // Nếu người dùng chọn một bệnh nhân, cập nhật state
    if (result != null) {
      setState(() {
        _selectedPatient = result;
      });
    }
  }

  Future<void> _openDoctorSearch(BuildContext context) async {
    final result = await showSearch<UserAccount?>(
      context: context,
      delegate: DoctorSearchDelegate(ref),
    );
    if (result != null) setState(() => _selectedDoctor = result);
  }

  @override
  Widget build(BuildContext context) {
    // Chúng ta không cần provider tìm kiếm nữa, quay lại provider danh sách
    // final doctorsAsync = ref.watch(doctorListProvider(""));
    final doctorsAsync = ref.watch(doctorListProvider((searchQuery: '', specialtyId: null)));
    // final patientsAsync = ref.watch(patientListProvider); // Truyền chuỗi rỗng để lấy tất cả
    final patientsAsync = ref.watch(patientListProvider("")); 

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Lịch hẹn cho Bệnh nhân')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown chọn bệnh nhân
            // Text('1. Tìm và chọn Bệnh nhân', style: Theme.of(context).textTheme.titleMedium),
            // const SizedBox(height: 8),
            // UserSearchField(
            //   provider: patientListProvider, // Sử dụng provider tìm kiếm
            //   label: 'Tìm kiếm bệnh nhân...',
            //   onSelected: (patient) {
            //     setState(() {
            //       _selectedPatient = patient;
            //     });
            //   },
            // ),
            const Text('1. Chọn Bệnh nhân', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // <<< THAY THẾ DROPDOWN BẰNG Ô TÌM KIẾM NÀY >>>
            Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: Text(_selectedPatient?.fullName ?? 'Nhấn để tìm kiếm bệnh nhân'),
                trailing: _selectedPatient != null ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => setState(() => _selectedPatient = null),
                ) : null,
                onTap: () => _openPatientSearch(context),
              ),
            ),

            
            const SizedBox(height: 16),

            const Text('2. Chọn Bác sĩ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // <<< THAY THẾ DROPDOWN BẰNG Ô TÌM KIẾM NÀY >>>
            Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: Text(_selectedDoctor != null ? 'BS. ${_selectedDoctor!.fullName}' : 'Nhấn để tìm kiếm bác sĩ'),
                trailing: _selectedDoctor != null ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => setState(() => _selectedDoctor = null),
                ) : null,
                onTap: () => _openDoctorSearch(context),
              ),
            ),
            // Dropdown chọn bác sĩ
            // doctorsAsync.when(
            //   loading: () => const CircularProgressIndicator(),
            //   error: (e, s) => Text('Lỗi: $e'),
            //   data: (doctors) => DropdownButtonFormField<UserAccount>(
            //     value: _selectedDoctor,
            //     hint: const Text('Chọn bác sĩ'),
            //     isExpanded: true,
            //     items: doctors.map((doctor) => DropdownMenuItem(
            //       value: doctor,
            //       child: Text('BS. ${doctor.lastName} ${doctor.firstName}'),
            //     )).toList(),
            //     onChanged: (value) => setState(() => _selectedDoctor = value),
            //   ),
            // ),
            
            const Spacer(), // Đẩy nút bấm xuống dưới cùng

            // <<< THAY ĐỔI 3: Thêm logic vào nút "Tiếp tục" >>>
            ElevatedButton(
              onPressed: (_selectedPatient != null && _selectedDoctor != null)
                  ? () {
                      // Điều hướng đến màn hình chọn thời gian,
                      // truyền ID của bệnh nhân và bác sĩ qua query parameters.
                      context.push(
                        '/receptionist/dashboard/create-appointment/select-time?doctorId=${_selectedDoctor!.id}&patientId=${_selectedPatient!.id}'
                      );
                    }
                  : null, // Vô hiệu hóa nút nếu chưa chọn đủ
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      ),
    );
  }
}
