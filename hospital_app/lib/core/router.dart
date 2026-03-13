// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';

// Import các provider và các màn hình liên quan
import 'package:hospital_app/providers/auth_provider.dart';
import 'package:hospital_app/providers/auth_state.dart';

// các screen 
import 'package:hospital_app/screens/auth/login_screen.dart';
import 'package:hospital_app/screens/auth/register_screen.dart';
import 'package:hospital_app/screens/patient/patient_home_screen.dart';
import 'package:hospital_app/screens/doctor/doctor_list_screen.dart';
import 'package:hospital_app/screens/patient/global_search_screen.dart';
import 'package:hospital_app/screens/patient/service_list_screen.dart';
// màn hình doctor

import 'package:hospital_app/screens/doctor/doctor_home_screen.dart';
import 'package:hospital_app/screens/doctor/doctor_appointments_screen.dart';
import 'package:hospital_app/screens/receptionist/receptionist_home_screen.dart';
import 'package:hospital_app/screens/admin/admin_dashboard.dart';
import 'package:hospital_app/screens/booking/appointment_booking_screen.dart';
import 'package:hospital_app/screens/appointments/appointments_screen.dart';
import 'package:hospital_app/screens/doctor/patient_medical_record_screen.dart';
import 'package:hospital_app/screens/receptionist/receptionist_appointments_screen.dart';
import 'package:hospital_app/screens/receptionist/receptionist_create_appointment_screen.dart';
import 'package:hospital_app/screens/profile/profile_screen.dart';
import 'package:hospital_app/screens/profile/edit_profile_screen.dart';
import 'package:hospital_app/screens/doctor/encounter_screen.dart'; // <<< THÊM
import 'package:hospital_app/models/appointment.dart';
import 'package:hospital_app/screens/patient/medical_results_screen.dart';
import 'package:hospital_app/screens/patient/encounter_detail_screen.dart'; // <<< THÊM
import 'package:hospital_app/models/encounter.dart';
import 'package:hospital_app/screens/receptionist/patient_management_screen.dart';
import 'package:hospital_app/screens/receptionist/patient_detail_screen.dart';
import 'package:hospital_app/screens/doctor/doctor_schedule_screen.dart';
import 'package:hospital_app/screens/doctor/doctor_patient_list_screen.dart';
import 'package:hospital_app/screens/booking/booking_options_screen.dart';
import 'package:hospital_app/screens/booking/specialty_list_screen.dart';

//Màn hình Admin
import 'package:hospital_app/screens/admin/admin_user_list_screen.dart';
import 'package:hospital_app/screens/admin/admin_create_user_screen.dart';
import 'package:hospital_app/screens/admin/admin_user_detail_screen.dart';
import 'package:hospital_app/screens/admin/admin_specialty_management_screen.dart';
import 'package:hospital_app/screens/admin/admin_service_management_screen.dart';
import 'package:hospital_app/screens/admin/admin_medicine_management_screen.dart';
import 'package:hospital_app/screens/admin/admin_stock_history_screen.dart';
import 'package:hospital_app/screens/admin/admin_appointments_monitoring_screen.dart';
import 'package:hospital_app/screens/admin/admin_manage_schedule_for_doctor_screen.dart';
import 'package:hospital_app/screens/admin/admin_reports_screen.dart';
import 'package:hospital_app/screens/admin/admin_patient_medical_history_screen.dart';
import 'package:hospital_app/screens/admin/admin_voucher_list_screen.dart'; 
import 'package:hospital_app/screens/admin/admin_create_voucher_screen.dart';
import 'package:hospital_app/screens/patient/chatbot_screen.dart';
// Provider để cung cấp instance GoRouter cho toàn bộ ứng dụng
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    // <<< PHẦN SỬA LỖI CHÍNH NẰM Ở ĐÂY >>>
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = authState.status == AuthStatus.authenticated;
      final String? userRole = authState.userRole;
      
      // <<< THAY ĐỔI 1: Xác định các trang công khai (public) >>>
      // Đây là những trang mà người dùng chưa đăng nhập vẫn được phép vào.
      final isAtLoginPage = state.matchedLocation == '/login';
      final isAtRegisterPage = state.matchedLocation == '/register';
      final isGoingToPublicPage = isAtLoginPage || isAtRegisterPage;

      // Kịch bản 1: Người dùng chưa đăng nhập
      // <<< THAY ĐỔI 2: Cập nhật quy tắc của "người bảo vệ" >>>
      // Nếu người dùng chưa đăng nhập VÀ họ đang không đi đến một trang công khai,
      // thì mới chuyển họ về trang login.
      if (!isLoggedIn && !isGoingToPublicPage) {
        return '/login';
      }

      // Kịch bản 2: Người dùng đã đăng nhập thành công
      // Nếu họ đang ở một trang công khai (login hoặc register), chuyển họ vào trong.
      if (isLoggedIn && isGoingToPublicPage) {
        switch (userRole) {
          case 'ADMIN':
            return '/admin/dashboard';
          case 'DOCTOR':
            return '/doctor/schedule';
          case 'RECEPTIONIST':
            return '/receptionist/dashboard';
          case 'PATIENT':
            return '/patient/home';
          default:
            return '/login';
        }
      }
      
      // Trong các trường hợp còn lại, không làm gì cả.
      return null;
    },

    // Danh sách các route không thay đổi
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => EditProfileScreen(user: state.extra as UserAccount),
    )
        ]
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'users', // URL sẽ là /admin/dashboard/users
            builder: (context, state) => const AdminUserListScreen(),
            routes: [
              GoRoute(
                path: 'create', // /admin/dashboard/users/create
                builder: (context, state) => const AdminCreateUserScreen(),
              ),
              
              GoRoute(
                path: ':userId', // /admin/dashboard/users/123
                builder: (context, state) {
                  final userId = int.parse(state.pathParameters['userId']!);
                  return AdminUserDetailScreen(userId: userId);
                },
                routes: [
                  GoRoute(
                    path: 'schedule', // URL sẽ là /admin/dashboard/users/123/schedule
                    builder: (context, state) {
                      // Lấy đối tượng UserAccount được truyền qua `extra`
                      final doctor = state.extra as UserAccount;
                      return AdminManageScheduleForDoctorScreen(doctor: doctor);
                    },
                  ),
                  GoRoute(
                        path: 'medical-history', // URL: /admin/dashboard/users/{id}/medical-history
                        builder: (context, state) {
                            final patient = state.extra as UserAccount;
                            return AdminPatientMedicalHistoryScreen(patient: patient);
                        },
                    ),
                ],
              ),
            ]
          ),
          GoRoute(
            path: 'reports', // URL sẽ là /admin/dashboard/reports
            builder: (context, state) => const AdminReportsScreen(),
          ),
          GoRoute(
                path: 'vouchers', // URL: /admin/dashboard/vouchers
                builder: (context, state) => const AdminVoucherListScreen(),
                routes: [
                  GoRoute(
                    path: 'create', // /admin/dashboard/vouchers/create
                    builder: (context, state) => const AdminCreateVoucherScreen(),
                  ),
                //   GoRoute(
                //     path: ':voucherId', // /admin/dashboard/vouchers/123
                //     builder: (context, state) => /* AdminVoucherDetailScreen */,
                //   ),
                ]
          ),
          GoRoute(
                path: 'specialties', // URL sẽ là /admin/dashboard/specialties
                builder: (context, state) => const AdminSpecialtyManagementScreen(),
          ),
          GoRoute(
            path: 'services', // URL sẽ là /admin/dashboard/services
            builder: (context, state) => const AdminServiceManagementScreen(),
          ),
          GoRoute(
            path: 'medicines', // URL sẽ là /admin/dashboard/medicines
            builder: (context, state) => const AdminMedicineManagementScreen(),
          ),
          GoRoute(
            path: 'stock-history', // URL: /admin/dashboard/stock-history
            builder: (context, state) => const AdminStockHistoryScreen(),
          ),
          GoRoute(
            path: 'appointments', // URL sẽ là /admin/dashboard/appointments
            builder: (context, state) => const AdminAppointmentsMonitoringScreen(),
          ),
        ],
      ),



      GoRoute(
        path: '/doctor/schedule', // Path trang chủ
        builder: (c, s) => const DoctorHomeScreen(),
        routes: [
          // 1. Luồng xem Lịch hẹn chờ khám
          GoRoute(
            path: 'appointments', // => /doctor/home/appointments
            builder: (c, s) => const DoctorAppointmentsScreen(),
            routes: [
              // Route để bắt đầu khám
              GoRoute(
                path: 'start-encounter', // => /doctor/home/appointments/start-encounter
                builder: (c, s) => EncounterScreen(appointment: s.extra as Appointment),
              ),
            ],
          ),

          // 2. Luồng xem Lịch làm việc
          GoRoute(
            path: 'my-schedule', // => /doctor/home/my-schedule
            builder: (c, s) => const DoctorScheduleScreen(),
          ),

          // 3. Luồng xem Danh sách Bệnh nhân
          GoRoute(
            path: 'my-patients', // => /doctor/home/my-patients
            builder: (c, s) => const DoctorPatientListScreen(),
            routes: [
              // Route để xem toàn bộ bệnh án của 1 bệnh nhân
              GoRoute(
                path: ':patientId/record', // => /doctor/home/my-patients/5/record
                builder: (c, s) {
                  final patientId = int.parse(s.pathParameters['patientId']!);
                  final patientName = s.uri.queryParameters['patientName'] ?? 'Bệnh nhân';
                  return PatientMedicalRecordScreen(patientId: patientId, patientName: patientName);
                  
                },
                routes: [
                  // Route con để xem chi tiết 1 bệnh án
                  GoRoute(
                    path: 'detail',
                    builder: (c, s) => EncounterDetailScreen(encounter: s.extra as Encounter),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),



  //     GoRoute(
  //       path: '/receptionist/dashboard',
  //       builder: (context, state) => const ReceptionistHomeScreen(),
  //       routes: [
  //     GoRoute(
  //     path: 'manage-appointments',
  //     builder: (context, state) => const ReceptionistAppointmentsScreen(),
  //     ),
      
  //     GoRoute(
  //     path: 'manage-patients',
  //     builder: (context, state) => const PatientManagementScreen(),
  //     routes: [
  //       GoRoute(
  //       path: ':patientId', 
  //       builder: (context, state) {
  //       final patientId = int.parse(state.pathParameters['patientId']!);
  //         return PatientDetailScreen(patientId: patientId);
  //       },
  //       routes: [
  //                 GoRoute(
  //                   path: 'encounter-detail', // Path sẽ khớp với URL
  //                   builder: (context, state) {
  //                     // Logic giống hệt như của Bệnh nhân
  //                     final encounter = state.extra as Encounter;
  //                     return EncounterDetailScreen(encounter: encounter);
  //                   },
  //                 ),
  //               ],
  //       ),
      
  //     ]
  //     ),
  //     GoRoute(
  //     path: 'create-appointment',
  //     builder: (context, state) => const ReceptionistCreateAppointmentScreen(),
  //     routes: [
  //           GoRoute(
  //               // Path sẽ có dạng: /receptionist/dashboard/create-appointment/select-time
  //               // Chúng ta sẽ truyền doctorId và patientId qua query params
  //               path: 'select-time', 
  //               builder: (context, state) {
  //                   final doctorId = int.parse(state.uri.queryParameters['doctorId']!);
  //                   final patientId = int.parse(state.uri.queryParameters['patientId']!);
  //                   return AppointmentBookingScreen(doctorId: doctorId, patientId: patientId);
  //               },
  //           ),
  //       ],
  //   ),
  // ],
  //     ),


      GoRoute(
        path: '/receptionist/dashboard',
        builder: (c, s) => const ReceptionistHomeScreen(),
        routes: [
          GoRoute(path: 'manage-appointments', builder: (c, s) => const ReceptionistAppointmentsScreen()),
          GoRoute(
            path: 'manage-patients',
            builder: (c, s) => const PatientManagementScreen(),
            routes: [
              GoRoute(
                path: ':patientId',
                builder: (c, s) => PatientDetailScreen(patientId: int.parse(s.pathParameters['patientId']!)),
                routes: [
                  GoRoute(
                    path: 'encounter-detail',
                    builder: (c, s) => EncounterDetailScreen(encounter: s.extra as Encounter),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'create-appointment',
            builder: (c, s) => const ReceptionistCreateAppointmentScreen(),
            routes: [
              GoRoute(
                path: 'select-time',
                builder: (c, s) {
                  final doctorId = int.parse(s.uri.queryParameters['doctorId']!);
                  final patientId = int.parse(s.uri.queryParameters['patientId']!);
                  return AppointmentBookingScreen(doctorId: doctorId, patientId: patientId);
                },
              ),
            ],
          ),
          // <<< THÊM ROUTE MỚI CHO LUỒNG TẠO LỊCH NHANH >>>
          GoRoute(
            path: 'create-for-patient/:patientId',
            builder: (context, state) {
              final patientId = int.parse(state.pathParameters['patientId']!);
              // Mở màn hình chọn bác sĩ và truyền patientId theo
              return DoctorListScreen(patientIdForBooking: patientId);
            },
            routes: [
              GoRoute(
                path: ':doctorId',
                builder: (context, state) {
                  final patientId = int.parse(state.pathParameters['patientId']!);
                  final doctorId = int.parse(state.pathParameters['doctorId']!);
                  // Đi thẳng đến màn hình booking với đầy đủ thông tin
                  return AppointmentBookingScreen(doctorId: doctorId, patientId: patientId);
                },
              ),
            ],
          ),
        ],
      ),

      
      
      GoRoute(
        path: '/patient/home',
        builder: (context, state) => const PatientHomeScreen(),
        routes: [
          // A. CÁC TÍNH NĂNG CHÍNH
          GoRoute(
            path: 'my-appointments',
            builder: (context, state) => const AppointmentsScreen(),
          ),
          GoRoute(
            path: 'search', // /patient/home/search
            builder: (context, state) => const GlobalSearchScreen(),
          ),
          GoRoute(
            path: 'all-services', // URL sẽ là /patient/home/all-services
            builder: (context, state) => const ServiceListScreen(),
          ),
          GoRoute(
            path: 'chatbot', // /patient/home/chatbot
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: 'medical-results',
            builder: (context, state) => const MedicalResultsScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final encounter = state.extra as Encounter;
                  return EncounterDetailScreen(encounter: encounter);
                },
              ),
            ],
          ),

          // B. LUỒNG ĐẶT LỊCH HẸN
          // B1. Màn hình lựa chọn
          GoRoute(
            path: 'book-appointment',
            builder: (context, state) => const BookingOptionsScreen(),
          ),

          // B2. Nhánh "Tìm theo Chuyên khoa"
          GoRoute(
            path: 'select-specialty',
            builder: (context, state) => const SpecialtyListScreen(),
          ),

          // B3. Nhánh "Tìm theo Dịch vụ" (sau khi đã chọn chuyên khoa)
          // GoRoute(
          //   // URL: /patient/home/select-service/3
          //   path: 'select-service/:specialtyId',
          //   builder: (context, state) {
          //     final specialtyId = int.parse(state.pathParameters['specialtyId']!);
          //     return ServiceListScreen(specialtyId: specialtyId);
          //   },
          // ),
          
          // B4. Nhánh "Tìm theo Bác sĩ" (hiển thị tất cả bác sĩ)
          GoRoute(
            path: 'search-doctor',
            builder: (context, state) => const DoctorListScreen(), // specialtyId sẽ là null
            routes: [
              GoRoute(
                path: ':doctorId',
                builder: (context, state) {
                  final doctorId = int.parse(state.pathParameters['doctorId']!);
                  return AppointmentBookingScreen(doctorId: doctorId);
                },
              ),
            ],
          ),

          // B5. Màn hình chung để hiển thị danh sách bác sĩ ĐÃ LỌC
          GoRoute(
            // URL: /patient/home/doctors-by-specialty/3
            path: 'doctors-by-specialty/:specialtyId',
            builder: (context, state) {
              final specialtyId = int.parse(state.pathParameters['specialtyId']!);
              return DoctorListScreen(specialtyId: specialtyId);
            },
            routes: [
              // Route con này giống hệt nhánh tìm kiếm
              GoRoute(
                path: ':doctorId',
                builder: (context, state) {
                  final doctorId = int.parse(state.pathParameters['doctorId']!);
                  return AppointmentBookingScreen(doctorId: doctorId);
                },
              ),
            ],
          ),
        ],
      ),

    ],
  );
});