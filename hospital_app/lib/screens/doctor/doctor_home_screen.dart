// // lib/screens/doctor/doctor_home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/providers/auth_provider.dart';
// import 'package:go_router/go_router.dart';


// class DoctorHomeScreen extends ConsumerWidget {
//   const DoctorHomeScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Trang chủ Bác sĩ'),
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
//             icon: Icons.calendar_view_week_rounded,
//             label: 'Lịch Làm Việc',
//             onTap: () {
//               context.push('/doctor/schedule/my-schedule');
//             },
//           ),
//           _buildFeatureCard(
//             context: context,
//             icon: Icons.access_time_filled_rounded,
//             label: 'Lịch Hẹn Khám',
//             onTap: () {
//               context.push('/doctor/schedule/appointments');
//             },
//           ),
//           _buildFeatureCard(
//             context: context,
//             icon: Icons.groups_rounded,
//             label: 'Danh sách Bệnh nhân',
//             onTap: () {
//               context.push('/doctor/schedule/my-patients');
//             },
//           ),
//           _buildFeatureCard(
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

// lib/screens/doctor/doctor_home_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/auth_provider.dart';

// <<< THÊM MỚI: Import các provider cần thiết >>>
import 'package:hospital_app/providers/user_provider.dart';
import 'package:hospital_app/providers/doctor_provider.dart';
import 'package:hospital_app/providers/appointments_provider.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  static const Color accent = Color.fromARGB(255, 62, 108, 209); // 💙 xanh dương chuyên nghiệp
  static const double radius = 18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Trang chủ Bác sĩ'),
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
              const _HeaderBanner(), // <<< Widget này sẽ được thay đổi
              const SizedBox(height: 16),
              _MainActionCards(
                onSchedule: () => context.push('/doctor/schedule/my-schedule'),
                onAppointments: () => context.push('/doctor/schedule/appointments'),
              ),
              const SizedBox(height: 16),
              _ServiceGrid(
                onPatients: () => context.push('/doctor/schedule/my-patients'),
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
}

// <<< THAY ĐỔI 1: Chuyển _HeaderBanner thành ConsumerWidget >>>
class _HeaderBanner extends ConsumerWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <<< Thêm WidgetRef ref
    final textTheme = Theme.of(context).textTheme;

    // <<< THAY ĐỔI 2: Lấy thông tin user, lịch làm việc, và lịch hẹn >>>
    final userProfileAsync = ref.watch(userProfileProvider);
    final recurringScheduleAsync = ref.watch(myRecurringScheduleProvider);

    return LayoutBuilder(builder: (context, c) {
      final maxByWidth = c.maxWidth * 0.35;
      final rightMax = math.min(140.0, maxByWidth);

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F0FF), Color(0xFFF4F8FF)], // 💙 xanh nhẹ y tế
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DoctorHomeScreen.radius * 1.2),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // <<< THAY ĐỔI 3: Hiển thị tên Bác sĩ động >>>
                  userProfileAsync.when(
                    data: (user) => Text(
                      'Xin chào, BS. ${user.firstName} 👋',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    loading: () => const Text('Xin chào!...'),
                    error: (e, s) => const Text('Xin chào, Bác sĩ 👋'),
                  ),
                  const SizedBox(height: 4),
                  Text('Hãy cùng mang lại sức khỏe cho mọi người 💙',
                      style:
                          textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                  const SizedBox(height: 12),
                  
                  // <<< THAY ĐỔI 4: Hiển thị ca làm việc trong ngày động >>>
                  recurringScheduleAsync.when(
                    data: (schedules) {
                      // Logic tìm ca làm việc của ngày hôm nay
                      // weekday: 1 = Monday, ..., 7 = Sunday
                      // backend: 0 = Monday, ..., 6 = Sunday
                      final todayWeekday = DateTime.now().weekday - 1; 
                      final todaySchedule = schedules.where((s) => s.dayOfWeek == todayWeekday).toList();

                      if (todaySchedule.isEmpty) {
                        return const _MiniTag(icon: Icons.info_outline, label: 'Hôm nay không có ca trực');
                      }

                      // Nếu có, hiển thị ca trực
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: todaySchedule.map((s) {
                          final startTime = s.startTime.substring(0, 5);
                          final endTime = s.endTime.substring(0, 5);
                          return _MiniTag(
                            icon: Icons.schedule_rounded,
                            label: 'Ca làm: $startTime - $endTime',
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const SizedBox(height: 20),
                    error: (e,s) => const SizedBox.shrink(),
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: rightMax),
                child: _TodayStatsCard(), // <<< Truyền ref vào widget này
              ),
            ),
          ],
        ),
      );
    });
  }
}

// <<< THAY ĐỔI 5: Chuyển _TodayStatsCard thành ConsumerWidget >>>
class _TodayStatsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    return Container(
      // <<< BỎ CHIỀU RỘNG CỐ ĐỊNH, ĐỂ EXPANDED TỰ QUYẾT ĐỊNH >>>
      // <<< THÊM CHIỀU CAO TỐI THIỂU ĐỂ CÂN ĐỐI HƠN >>>
      constraints: const BoxConstraints(minHeight: 100),
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
      // <<< BỌC NỘI DUNG TRONG CENTER ĐỂ CĂN GIỮA HOÀN HẢO >>>
      child: Center(
        child: appointmentsAsync.when(
          data: (appointments) {
            final today = DateUtils.dateOnly(DateTime.now());
            final todayAppointments = appointments.where((a) => 
              DateUtils.isSameDay(a.appointmentTime, today)
            ).toList();

            final checkedInCount = todayAppointments.where((a) => a.status == 'CHECKED_IN').length;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung cột
              crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa nội dung cột
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min, // Row co lại vừa đủ
                  children: [
                    Icon(Icons.monitor_heart_rounded, size: 16, color: DoctorHomeScreen.accent),
                    SizedBox(width: 6),
                    Text('Hôm nay'),
                  ]),
                const SizedBox(height: 8),
                Text('${todayAppointments.length} cuộc hẹn',
                    textAlign: TextAlign.center, // Căn giữa text
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)), // <<< TĂNG FONT SIZE
                const SizedBox(height: 4),
                Text('$checkedInCount đã check-in',
                    textAlign: TextAlign.center, // Căn giữa text
                    style: const TextStyle(fontSize: 14, color: Colors.black54)), // <<< TĂNG FONT SIZE
              ],
            );
          },
          loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
          error: (e, s) => const Text('Lỗi', style: TextStyle(fontSize: 13, color: Colors.red)),
        ),
      ),
    );
  }
}

// Các widget còn lại không cần thay đổi

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DoctorHomeScreen.accent.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DoctorHomeScreen.accent.withOpacity(.25)),
      ),
      child: Flexible(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: DoctorHomeScreen.accent),
        const SizedBox(width: 6),
        Expanded(child: Text(label,)),
      ]),
      ),
    );
  }
}

class _MainActionCards extends StatelessWidget {
  final VoidCallback onSchedule;
  final VoidCallback onAppointments;

  const _MainActionCards({
    required this.onSchedule,
    required this.onAppointments,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GradientCard(
            title: 'Lịch Làm Việc',
            subtitle: 'Xem và quản lý ca trực',
            icon: Icons.calendar_today_rounded,
            onTap: onSchedule,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WhiteCard(
            title: 'Lịch Hẹn Khám',
            subtitle: 'Danh sách bệnh nhân hôm nay',
            icon: Icons.access_time_rounded,
            onTap: onAppointments,
          ),
        ),
      ],
    );
  }
}

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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)], // 💙 xanh gradient
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
                Icon(icon, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ]),
              const Spacer(),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
      height: 120,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: DoctorHomeScreen.accent),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ]),
              const Spacer(),
              Text(subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

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
      _ServiceItem(Icons.groups_rounded, 'Bệnh nhân', onPatients),
      _ServiceItem(Icons.person_outline_rounded, 'Hồ sơ', onProfile),
      _ServiceItem(Icons.health_and_safety_rounded, 'Chuyên khoa', () {}),
      _ServiceItem(Icons.analytics_outlined, 'Thống kê', () {}),
      // _ServiceItem(Icons.insert_drive_file_rounded, 'Báo cáo', () {}),
      // _ServiceItem(Icons.settings_outlined, 'Cài đặt', () {}),
      // _ServiceItem(Icons.message_rounded, 'Tin nhắn', () {}),
      // _ServiceItem(Icons.more_horiz_rounded, 'Khác', () {}),
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
                backgroundColor: DoctorHomeScreen.accent.withOpacity(.12),
                child:
                    Icon(item.icon, size: 17, color: DoctorHomeScreen.accent),
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
            Icon(Icons.lightbulb_outline_rounded,
                color: DoctorHomeScreen.accent),
            SizedBox(width: 8),
            Text('Ghi chú nhanh', style: TextStyle(fontWeight: FontWeight.w700)),
          ]),
          SizedBox(height: 8),
          Text('• Kiểm tra hồ sơ bệnh án đã cập nhật.'),
          Text('• Hoàn thành biên bản ca trực trước 18:00.'),
          Text('• Gửi báo cáo tổng hợp hằng ngày cho quản lý.'),
        ],
      ),
    );
  }
}