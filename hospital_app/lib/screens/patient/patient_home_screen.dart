
// lib/screens/patient/patient_home_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/auth_provider.dart';
import 'package:intl/intl.dart'; // <<< THÊM MỚI: Để định dạng ngày tháng

// <<< THÊM MỚI: Import các provider cần thiết >>>
import 'package:hospital_app/providers/user_provider.dart';
import 'package:hospital_app/providers/appointments_provider.dart';
import 'package:hospital_app/models/appointment.dart';


class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  static const Color accent = Color(0xFF0BA5A4);
  static const double radius = 18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // <<< THÊM MỚI: Lắng nghe sự kiện refresh từ các provider con >>>
    // Khi lịch hẹn thay đổi, làm mới lại provider của user để có thể
    // cập nhật các thông tin liên quan (nếu có)
    ref.listen(patientAppointmentsProvider, (_, __) {
      ref.invalidate(userProfileProvider);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
            tooltip: 'Thông báo',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Điều hướng đến màn hình chatbot
          context.push('/patient/home/chatbot');
        },
        tooltip: 'Hỏi Trợ lý AI',
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              GestureDetector(
                onTap: () => context.push('/patient/home/search'), // Điều hướng đến trang tìm kiếm
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text('Tìm bác sĩ, dịch vụ, chuyên khoa...', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
              
              const _HeaderBanner(), // <<< Widget này sẽ được thay đổi nhiều nhất
              const SizedBox(height: 16),
              _FeaturedCards(
                onTapPrimary: () => context.push('/patient/home/book-appointment'),
                onTapSecondary: () => context.push('/patient/home/my-appointments'),
              ),
              const SizedBox(height: 16),
              // <<< THÊM MỚI: Truyền các route vào grid >>>
              _ServiceGrid(
                onBook: () => context.push('/patient/home/book-appointment'),
                onMyAppts: () => context.push('/patient/home/my-appointments'),
                onResults: () => context.push('/patient/home/medical-results'),
                onProfile: () => context.push('/profile'),
                // <<< Cập nhật các route còn thiếu >>>
                onSpecialty: () => context.push('/patient/home/select-specialty'),
                onDoctor: () => context.push('/patient/home/search-doctor'),
                onServices: () => context.push('/patient/home/all-services'),
              ),
              const SizedBox(height: 16),
              const _ReminderCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= Header Banner (responsive, no overflow) =================
// <<< THAY ĐỔI 1: Chuyển thành ConsumerWidget để truy cập ref >>>
class _HeaderBanner extends ConsumerWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <<< Thêm WidgetRef ref
    final textTheme = Theme.of(context).textTheme;
    
    // <<< THAY ĐỔI 2: Lấy thông tin user và lịch hẹn từ provider >>>
    final userProfileAsync = ref.watch(userProfileProvider);
    final appointmentsAsync = ref.watch(patientAppointmentsProvider);

    return LayoutBuilder(builder: (context, c) {
      final maxByWidth = c.maxWidth * 0.40;
      final double rightMax = math.min(150.0, maxByWidth);

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE0F7F6), Color(0xFFF2FBFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(PatientHomeScreen.radius * 1.2),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // <<< THAY ĐỔI 3: Hiển thị tên người dùng động >>>
                  userProfileAsync.when(
                    data: (user) => Text(
                      'Xin chào, ${user.firstName}!', // Sử dụng tên từ API
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    loading: () => const Text('Xin chào!...'), // Placeholder
                    error: (e, s) => const Text('Xin chào!'), // Fallback
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chúc bạn một ngày khoẻ mạnh ✨',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _MiniPill(icon: Icons.health_and_safety_outlined, label: 'Sức khoẻ'),
                      _MiniPill(icon: Icons.verified_user_outlined, label: 'Bảo mật'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // <<< THAY ĐỔI 4: Hiển thị thẻ lịch hẹn sắp tới >>>
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: rightMax),
                child: appointmentsAsync.when(
                  data: (appointments) {
                    // Logic tìm lịch hẹn gần nhất trong tương lai
                    final now = DateTime.now();
                    final upcomingAppointments = appointments.where((a) =>
                      a.appointmentTime.isAfter(now) &&
                      (a.status == 'CONFIRMED' || a.status == 'RECEPTIONIST_PROPOSED')
                    ).toList();

                    // Sắp xếp để tìm ra lịch gần nhất
                    upcomingAppointments.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

                    if (upcomingAppointments.isNotEmpty) {
                      return _NextAppointmentCard(appointment: upcomingAppointments.first);
                    }
                    // Nếu không có, hiển thị một widget khác
                    return const _NoAppointmentCard();
                  },
                  loading: () => const Center(child: SizedBox.shrink()),
                  error: (e, s) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// <<< THÊM MỚI: Widget hiển thị thẻ lịch hẹn sắp tới >>>
class _NextAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/patient/home/my-appointments'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PatientHomeScreen.radius),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Lịch hẹn sắp tới",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: PatientHomeScreen.accent,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(appointment.appointmentTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                 const Icon(Icons.access_time_rounded, size: 12, color: Colors.black54),
                 const SizedBox(width: 4),
                 Text(
                  DateFormat('HH:mm').format(appointment.appointmentTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// <<< THÊM MỚI: Widget hiển thị khi không có lịch hẹn >>>
class _NoAppointmentCard extends StatelessWidget {
  const _NoAppointmentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(PatientHomeScreen.radius),
        border: Border.all(color: Colors.black.withOpacity(0.05))
      ),
      child: Center(
        child: Icon(
          Icons.event_available,
          color: PatientHomeScreen.accent.withOpacity(0.5),
          size: 40,
        ),
      ),
    );
  }
}


// Widget _MiniPill không thay đổi...
class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniPill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PatientHomeScreen.accent.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PatientHomeScreen.accent.withOpacity(.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: PatientHomeScreen.accent),
        const SizedBox(width: 6),
        Text(label, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}


// Widget _FeaturedCards không thay đổi...
class _FeaturedCards extends StatelessWidget {
  final VoidCallback onTapPrimary;
  final VoidCallback onTapSecondary;
  const _FeaturedCards({required this.onTapPrimary, required this.onTapSecondary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0BA5A4), Color(0xFF22C55E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTapPrimary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.calendar_month_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Đặt lịch nhanh',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ]),
                      const Spacer(),
                      Text(
                        'Chọn bác sĩ, chọn giờ, xác nhận',
                        style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 8)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTapSecondary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.history_rounded, color: PatientHomeScreen.accent),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Các lịch hẹn',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ]),
                      const Spacer(),
                      Text(
                        'Xem và quản lý tất cả lịch của bạn',
                        style: textTheme.bodySmall?.copyWith(color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


/// ================= Services Grid =================
class _ServiceGrid extends StatelessWidget {
  // <<< THÊM MỚI: Thêm 2 callback onSpecialty và onDoctor >>>
  final VoidCallback onBook, onMyAppts, onResults, onProfile, onSpecialty, onDoctor, onServices;
  const _ServiceGrid({
    required this.onBook,
    required this.onMyAppts,
    required this.onResults,
    required this.onProfile,
    required this.onSpecialty,
    required this.onDoctor,
    required this.onServices,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ServiceItem(Icons.calendar_month_outlined, 'Đặt lịch', onBook),
      _ServiceItem(Icons.view_list_outlined, 'Lịch của tôi', onMyAppts),
      _ServiceItem(Icons.assignment_turned_in_outlined, 'Kết quả khám', onResults),
      _ServiceItem(Icons.person_outline, 'Hồ sơ', onProfile),
      _ServiceItem(Icons.local_hospital_outlined, 'Chuyên khoa', onSpecialty), // <<< Gán callback
      _ServiceItem(Icons.groups_2_outlined, 'Bác sĩ', onDoctor), // <<< Gán callback
     _ServiceItem(Icons.medical_information_outlined, 'Dịch vụ', onServices),
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

// Widget _ServiceItem và _ServiceTile không thay đổi...
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
                backgroundColor: PatientHomeScreen.accent.withOpacity(.12),
                child: Icon(item.icon, size: 17, color: PatientHomeScreen.accent),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Widget _ReminderCard không thay đổi...
class _ReminderCard extends StatelessWidget {
  const _ReminderCard();
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.tips_and_updates_outlined, color: PatientHomeScreen.accent),
            SizedBox(width: 8),
            Text('Lời nhắc cho bạn', style: TextStyle(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text('• Cập nhật thông tin hồ sơ để nhận tư vấn chính xác hơn.', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('• Bật thông báo để không bỏ lỡ lịch hẹn.', style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
