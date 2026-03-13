// // lib/screens/receptionist/receptionist_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/providers/auth_provider.dart';
// import 'package:go_router/go_router.dart';

// class ReceptionistHomeScreen extends ConsumerWidget {
//   const ReceptionistHomeScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Trang chủ Lễ tân'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Đăng xuất',
//             onPressed: () => ref.read(authProvider.notifier).logout(),
//           ),
//         ],
//       ),
//       body: GridView.count(
//         padding: const EdgeInsets.all(16.0),
//         crossAxisCount: 2,
//         crossAxisSpacing: 16.0,
//         mainAxisSpacing: 16.0,
//         children: [
//           _buildFeatureCard(
//             context: context,
//             icon: Icons.book_online_rounded,
//             label: 'Quản lý Lịch hẹn',
//             onTap: () {
//               context.push('/receptionist/dashboard/manage-appointments');
//             },
//           ),
//           _buildFeatureCard(
//             context: context,
//             icon: Icons.person_add_alt_1_rounded,
//             label: 'Tạo Lịch hẹn mới',
//             onTap: () {
//               context.push('/receptionist/dashboard/create-appointment');
//             },
//           ),
//           _buildFeatureCard(
//             context: context,
//             icon: Icons.folder_shared_outlined,
//             label: 'Quản lý Bệnh nhân',
//             onTap: () {
//               context.push('/receptionist/dashboard/manage-patients');
//             },
//           ),
//            _buildFeatureCard(
//             context: context,
//             icon: Icons.person_outline_rounded,
//             label: 'Hồ Sơ Cá Nhân',
//             onTap: () {
//               context.push('/profile');
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget helper để tạo các ô chức năng
//   Widget _buildFeatureCard({
//     required BuildContext context,
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     final theme = Theme.of(context);
//     return Card(
//       elevation: 4.0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 48.0, color: theme.primaryColor),
//             const SizedBox(height: 16.0),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.titleMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/receptionist/receptionist_home_screen.dart
// lib/screens/receptionist/receptionist_home_screen.dart

// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hospital_app/providers/auth_provider.dart';

// // <<< THÊM MỚI: Import các provider cần thiết >>>
// import 'package:hospital_app/providers/user_provider.dart';
// import 'package:hospital_app/providers/appointments_provider.dart';

// class ReceptionistHomeScreen extends ConsumerWidget {
//   const ReceptionistHomeScreen({super.key});

//   static const Color accent = Color(0xFF0BA5A4); 
//   static const double radius = 18;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7FA),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: const Text('Trang chủ Lễ tân'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_none_rounded),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Đăng xuất',
//             onPressed: () => ref.read(authProvider.notifier).logout(),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const _HeaderBanner(), // <<< Widget này sẽ được thay đổi
//               const SizedBox(height: 16),
//               _MainActionCards(
//                 onManageAppointments: () =>
//                     context.push('/receptionist/dashboard/manage-appointments'),
//                 onCreateAppointment: () =>
//                     context.push('/receptionist/dashboard/create-appointment'),
//               ),
//               const SizedBox(height: 16),
//               _ServiceGrid(
//                 onPatients: () =>
//                     context.push('/receptionist/dashboard/manage-patients'),
//                 onProfile: () => context.push('/profile'),
//               ),
//               const SizedBox(height: 16),

//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // <<< THAY ĐỔI 1: Chuyển _HeaderBanner thành ConsumerWidget >>>
// class _HeaderBanner extends ConsumerWidget {
//   const _HeaderBanner();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) { // <<< Thêm WidgetRef ref
//     final textTheme = Theme.of(context).textTheme;
    
//     // <<< THAY ĐỔI 2: Lấy thông tin user từ provider >>>
//     final userProfileAsync = ref.watch(userProfileProvider);

//     return LayoutBuilder(builder: (context, c) {
//       final maxByWidth = c.maxWidth * 0.35;
//       final rightMax = math.min(140.0, maxByWidth);

//       return Container(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFFE0F7F6), Color(0xFFF2FBFB)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius:
//               BorderRadius.circular(ReceptionistHomeScreen.radius * 1.2),
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // <<< THAY ĐỔI 3: Hiển thị tên Lễ tân động >>>
//                   userProfileAsync.when(
//                     data: (user) => Text(
//                       'Xin chào, ${user.firstName}!', // Sử dụng tên từ API
//                       style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//                     ),
//                     loading: () => const Text('Xin chào!...'),
//                     error: (e,s) => const Text('Xin chào, Lễ tân!'),
//                   ),
//                   const SizedBox(height: 4),
//                   Text('Chúc bạn một ca trực hiệu quả ✨',
//                       style:
//                           textTheme.bodyMedium?.copyWith(color: Colors.black54)),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: const [
//                       _MiniTag(
//                           icon: Icons.support_agent_rounded, label: 'Trực lễ tân'),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             Flexible(
//               fit: FlexFit.loose,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: rightMax),
//                 // <<< THAY ĐỔI 4: Truyền ref vào _TodayStatsCard để lấy dữ liệu động >>>
//                 child: _TodayStatsCard(), 
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// // <<< THAY ĐỔI 5: Chuyển _TodayStatsCard thành ConsumerWidget >>>
// class _TodayStatsCard extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) { // <<< Thêm WidgetRef ref
//     // <<< THAY ĐỔI 6: Lấy danh sách lịch hẹn từ provider >>>
//     final appointmentsAsync = ref.watch(receptionistAppointmentsProvider);

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.05),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: const [
//             Icon(Icons.event_available,
//                 size: 16, color: ReceptionistHomeScreen.accent),
//             SizedBox(width: 6),
//             Text('Hôm nay'),
//           ]),
//           const SizedBox(height: 8),
          
//           // <<< THAY ĐỔI 7: Dùng .when để hiển thị số lịch hẹn động >>>
//           appointmentsAsync.when(
//             data: (appointments) {
//               final today = DateUtils.dateOnly(DateTime.now());
//               // Đếm số lịch hẹn có ngày là hôm nay
//               final todayCount = appointments.where((a) => 
//                 DateUtils.isSameDay(a.appointmentTime, today)
//               ).length;
              
//               // Đếm số bệnh nhân chờ xác nhận
//               final pendingCount = appointments.where((a) =>
//                 a.status == 'PATIENT_REQUESTED'
//               ).length;
              
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('$todayCount lịch hẹn',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   Text('$pendingCount chờ xử lý',
//                     style: const TextStyle(fontSize: 13, color: Colors.black54)),
//                 ],
//               );
//             },
//             loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2,))),
//             error: (e, s) => const Text('Lỗi', style: TextStyle(fontSize: 13, color: Colors.red)),
//           )
//         ],
//       ),
//     );
//   }
// }


// // Các widget còn lại không cần thay đổi
// class _MiniTag extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   const _MiniTag({required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: ReceptionistHomeScreen.accent.withOpacity(.1),
//         borderRadius: BorderRadius.circular(20),
//         border:
//             Border.all(color: ReceptionistHomeScreen.accent.withOpacity(.25)),
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 14, color: ReceptionistHomeScreen.accent),
//         const SizedBox(width: 6),
//         Text(label),
//       ]),
//     );
//   }
// }

// class _MainActionCards extends StatelessWidget {
//   final VoidCallback onManageAppointments;
//   final VoidCallback onCreateAppointment;

//   const _MainActionCards({
//     required this.onManageAppointments,
//     required this.onCreateAppointment,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _GradientCard(
//             title: 'Quản lý Lịch hẹn',
//             subtitle: 'Theo dõi & sắp xếp lịch khám',
//             icon: Icons.calendar_month_rounded,
//             onTap: onManageAppointments,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _WhiteCard(
//             title: 'Tạo Lịch hẹn mới',
//             subtitle: 'Thêm nhanh thông tin bệnh nhân',
//             icon: Icons.add_circle_outline_rounded,
//             onTap: onCreateAppointment,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _GradientCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _GradientCard({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 120,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF0BA5A4), Color(0xFF22C55E)], // 💚 gradient xanh
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(children: [
//                 Icon(icon, color: Colors.white),
//                 const SizedBox(width: 6),
//                 Flexible(
//                   child: Text(title,
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16)),
//                 ),
//               ]),
//               const Spacer(),
//               Text(subtitle,
//                   style: const TextStyle(color: Colors.white70, fontSize: 13)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _WhiteCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _WhiteCard({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 120,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(.05),
//               blurRadius: 10,
//               offset: const Offset(0, 8))
//         ],
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(children: [
//                 Icon(icon, color: ReceptionistHomeScreen.accent),
//                 const SizedBox(width: 6),
//                 Flexible(
//                   child: Text(title,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 16)),
//                 ),
//               ]),
//               const Spacer(),
//               Text(subtitle,
//                   style: const TextStyle(color: Colors.black54, fontSize: 13)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ServiceGrid extends StatelessWidget {
//   final VoidCallback onPatients;
//   final VoidCallback onProfile;

//   const _ServiceGrid({
//     required this.onPatients,
//     required this.onProfile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       _ServiceItem(Icons.folder_shared_rounded, 'Bệnh nhân', onPatients),
//       _ServiceItem(Icons.person_outline_rounded, 'Hồ sơ', onProfile),
//       _ServiceItem(Icons.support_agent_rounded, 'Bác sĩ', () {}),
//       _ServiceItem(Icons.dashboard_customize_outlined, 'Phòng ban', () {}),
//       _ServiceItem(Icons.query_stats_rounded, 'Báo cáo', () {}),
//       _ServiceItem(Icons.verified_user_outlined, 'Bảo mật', () {}),
//       _ServiceItem(Icons.message_outlined, 'Tin nhắn', () {}),
//       _ServiceItem(Icons.more_horiz_rounded, 'Khác', () {}),
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 0.78,
//       ),
//       itemBuilder: (context, i) => _ServiceTile(item: items[i]),
//     );
//   }
// }

// class _ServiceItem {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   const _ServiceItem(this.icon, this.label, this.onTap);
// }

// class _ServiceTile extends StatelessWidget {
//   final _ServiceItem item;
//   const _ServiceTile({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         onTap: item.onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 15,
//                 backgroundColor: ReceptionistHomeScreen.accent.withOpacity(.12),
//                 child:
//                     Icon(item.icon, size: 17, color: ReceptionistHomeScreen.accent),
//               ),
//               const SizedBox(height: 6),
//               Text(item.label,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 12),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/receptionist/receptionist_home_screen.dart

// import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/auth_provider.dart';
import 'package:hospital_app/providers/user_provider.dart';
import 'package:hospital_app/providers/appointments_provider.dart';

class ReceptionistHomeScreen extends ConsumerWidget {
  const ReceptionistHomeScreen({super.key});

  static const Color accent = Color(0xFF0BA5A4);
  static const double radius = 18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Trang chủ Lễ tân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // <<< THAY ĐỔI 1: TÁI CẤU TRÚC HOÀN TOÀN HEADER >>>
              // Header bây giờ bao gồm cả Card "Xin chào" và "Quản lý lịch hẹn"
              _buildHeaderSection(context, ref),
              const SizedBox(height: 16),

              // <<< THAY ĐỔI 2: DI CHUYỂN CARD "TẠO LỊCH HẸN MỚI" XUỐNG ĐÂY >>>
              // Nó sẽ nằm riêng một hàng, phía trên Grid
              _WhiteCard(
                title: 'Tạo Lịch hẹn mới',
                subtitle: 'Thêm nhanh thông tin bệnh nhân',
                icon: Icons.add_circle_outline_rounded,
                onTap: () => context.push('/receptionist/dashboard/create-appointment'),
              ),
              const SizedBox(height: 16),
              
              // Grid các dịch vụ còn lại
              _ServiceGrid(
                onPatients: () => context.push('/receptionist/dashboard/manage-patients'),
                onProfile: () => context.push('/profile'),
              ),
              const SizedBox(height: 16),
              const _NoteCard(),
            ],
          ),
        ),
      ),
    );
  }

  // <<< THAY ĐỔI 3: TẠO WIDGET BUILDER MỚI CHO TOÀN BỘ HEADER >>>
  Widget _buildHeaderSection(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trên cùng
      children: [
        // Cột bên trái chứa thông tin "Xin chào"
        const Expanded(
          child: _ReceptionistInfoCard(),
        ),
        const SizedBox(width: 12),
        // Cột bên phải chứa thông tin thống kê và card "Quản lý"
        Column(
          children: [
            _TodayStatsCard(),
            const SizedBox(height: 12),
            _GradientCard(
              title: 'Quản lý Lịch hẹn',
              subtitle: 'Theo dõi & sắp xếp lịch khám',
              icon: Icons.calendar_month_rounded,
              onTap: () => context.push('/receptionist/dashboard/manage-appointments'),
            ),
          ],
        ),
      ],
    );
  }
}

// <<< THAY ĐỔI 4: TÁCH CARD "XIN CHÀO" RA THÀNH WIDGET RIÊNG >>>
class _ReceptionistInfoCard extends ConsumerWidget {
  const _ReceptionistInfoCard();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final userProfileAsync = ref.watch(userProfileProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F7F6), Color(0xFFF2FBFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ReceptionistHomeScreen.radius * 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userProfileAsync.when(
            data: (user) => Text(
              'Xin chào, ${user.firstName}!',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            loading: () => const Text('Xin chào!...'),
            error: (e, s) => const Text('Xin chào, Lễ tân!'),
          ),
          const SizedBox(height: 4),
          Text('Chúc bạn một ngày làm việc hiệu quả ✨',
              style: textTheme.bodyMedium?.copyWith(color: Colors.black54)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _MiniTag(
                  icon: Icons.support_agent_rounded, label: 'Trực lễ tân'),
            ],
          ),
        ],
      ),
    );
  }
}


class _TodayStatsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(receptionistAppointmentsProvider);

    return Container(
      width: 140, // <<< Thêm chiều rộng cố định để dễ căn chỉnh
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.event_available,
                size: 16, color: ReceptionistHomeScreen.accent),
            SizedBox(width: 6),
            Text('Hôm nay'),
          ]),
          const SizedBox(height: 8),
          appointmentsAsync.when(
            data: (appointments) {
              final today = DateUtils.dateOnly(DateTime.now());
              final todayCount = appointments.where((a) => 
                DateUtils.isSameDay(a.appointmentTime, today)
              ).length;
              
              final pendingCount = appointments.where((a) =>
                a.status == 'PATIENT_REQUESTED'
              ).length;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$todayCount lịch hẹn',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('$pendingCount chờ xử lý',
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              );
            },
            loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2,))),
            error: (e, s) => const Text('Lỗi', style: TextStyle(fontSize: 13, color: Colors.red)),
          )
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ReceptionistHomeScreen.accent.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: ReceptionistHomeScreen.accent.withOpacity(.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: ReceptionistHomeScreen.accent),
        const SizedBox(width: 6),
        Text(label),
      ]),
    );
  }
}


// <<< THAY ĐỔI 5: XÓA WIDGET _MainActionCards VÌ KHÔNG CÒN SỬ DỤNG >>>


class _GradientCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 140, // <<< Thêm chiều rộng cố định để dễ căn chỉnh
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0BA5A4), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title,
                      maxLines: 2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ]),
              const Spacer(),
              Text(subtitle,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _WhiteCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // <<< BỎ CHIỀU CAO CỐ ĐỊNH ĐỂ NÓ TỰ DÃN >>>
      // height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 8))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Row( // <<< Chuyển thành Row để icon và text nằm cạnh nhau
          children: [
            Icon(icon, color: ReceptionistHomeScreen.accent, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Các widget còn lại không thay đổi...
class _ServiceGrid extends StatelessWidget {
  final VoidCallback onPatients;
  final VoidCallback onProfile;

  const _ServiceGrid({
    required this.onPatients,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ServiceItem(Icons.folder_shared_rounded, 'Bệnh nhân', onPatients),
      _ServiceItem(Icons.person_outline_rounded, 'Hồ sơ', onProfile),
      _ServiceItem(Icons.support_agent_rounded, 'Bác sĩ', () {}),
      _ServiceItem(Icons.dashboard_customize_outlined, 'Phòng ban', () {}),
      _ServiceItem(Icons.query_stats_rounded, 'Báo cáo', () {}),
      _ServiceItem(Icons.verified_user_outlined, 'Bảo mật', () {}),
      _ServiceItem(Icons.message_outlined, 'Tin nhắn', () {}),
      _ServiceItem(Icons.more_horiz_rounded, 'Khác', () {}),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) => _ServiceTile(item: items[i]),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ServiceItem(this.icon, this.label, this.onTap);
}

class _ServiceTile extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: ReceptionistHomeScreen.accent.withOpacity(.12),
                child:
                    Icon(item.icon, size: 17, color: ReceptionistHomeScreen.accent),
              ),
              const SizedBox(height: 6),
              Text(item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(children: [
            Icon(Icons.tips_and_updates_outlined,
                color: ReceptionistHomeScreen.accent),
            SizedBox(width: 8),
            Text('Ghi chú nhanh', style: TextStyle(fontWeight: FontWeight.w700)),
          ]),
          SizedBox(height: 8),
          Text('• Kiểm tra danh sách lịch hẹn buổi chiều.'),
          Text('• Cập nhật hồ sơ bệnh nhân mới.'),
          Text('• Báo cáo tổng hợp gửi quản lý trước 17:00.'),
        ],
      ),
    );
  }
}