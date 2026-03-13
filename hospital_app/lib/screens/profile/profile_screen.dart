// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân'),
        actions: [
          // <<< SỬA LỖI Ở ĐÂY >>>
          // Chỉ hiển thị nút Edit khi đã có dữ liệu user (trạng thái data)
          userState.when(
            data: (user) => IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Chỉnh sửa thông tin',
              onPressed: () {
                // Bây giờ biến `user` đã hợp lệ và có thể được truyền đi
                context.push('/profile/edit', extra: user);
              },
            ),
            // Khi đang loading hoặc có lỗi, không hiển thị nút nào cả
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: userState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải hồ sơ: $err')),
        data: (user) {
          return RefreshIndicator(
            onRefresh: () async {
              // Cho phép người dùng kéo để làm mới
              return ref.read(userProfileProvider.notifier).refreshProfile();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    // Nếu không có avatar, hiển thị chữ cái đầu của tên
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: user.avatar != null
                        ? NetworkImage(user.avatar!)
                        : null,
                    child: user.avatar == null
                        ? Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${user.lastName} ${user.firstName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const Divider(height: 32),
                // --- PHẦN THÔNG TIN CHUNG ---
                _buildSectionTitle(context, 'Thông tin Cơ bản'),
                _buildInfoTile(icon: Icons.person, title: 'Họ và Tên', subtitle: '${user.lastName} ${user.firstName}'),
                _buildInfoTile(icon: Icons.account_circle, title: 'Tên đăng nhập', subtitle: user.username),
                _buildInfoTile(icon: Icons.email_outlined, title: 'Email', subtitle: user.email),
                _buildInfoTile(icon: Icons.phone_android, title: 'Số điện thoại', subtitle: user.phoneNumber ?? 'Chưa cập nhật'),
                _buildInfoTile(icon: Icons.cake_outlined, title: 'Ngày sinh', subtitle: user.dateOfBirth != null ? DateFormat.yMd('vi_VN').format(user.dateOfBirth!) : 'Chưa cập nhật'),
                _buildInfoTile(icon: Icons.location_on_outlined, title: 'Địa chỉ', subtitle: user.address ?? 'Chưa cập nhật'),
                _buildInfoTile(icon: Icons.wc_outlined, title: 'Giới tính', subtitle: user.gender ?? 'Chưa cập nhật'),
                
                const Divider(height: 32),

                // --- PHẦN THÔNG TIN RIÊNG THEO VAI TRÒ ---
                _buildRoleSpecificProfile(context, user),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget helper để hiển thị thông tin riêng theo vai trò
  Widget _buildRoleSpecificProfile(BuildContext context, UserAccount user) {
    switch (user.role) {
      case 'PATIENT':
        final profile = user.profile as PatientProfile?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Thông tin Y tế'),
            // _buildInfoTile(icon: Icons.history_edu, title: 'Tiền sử bệnh án', subtitle: profile?.medicalHistory ?? 'Chưa có'),
            ListTile(
            leading: const Icon(Icons.history_edu_outlined),
            title: const Text('Lịch sử Khám bệnh'),
            subtitle: const Text('Xem lại tất cả các lần khám trước đây'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Điều hướng đến màn hình Kết Quả Khám đã có sẵn
              context.push('/patient/home/medical-results');
              },
            ),
            _buildInfoTile(icon: Icons.warning_amber_rounded, title: 'Dị ứng', subtitle: profile?.allergies ?? 'Chưa có'),
          ],
        );
      case 'DOCTOR':
        final profile = user.profile as DoctorProfile?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Thông tin Chuyên môn'),
            _buildInfoTile(icon: Icons.medical_services_outlined, title: 'Chuyên khoa', subtitle: profile?.specialtyName ?? 'Chưa cập nhật'),
            _buildInfoTile(icon: Icons.badge_outlined, title: 'Số giấy phép', subtitle: profile?.licenseNumber ?? 'Chưa cập nhật'),
            _buildInfoTile(icon: Icons.info_outline, title: 'Giới thiệu', subtitle: profile?.bio ?? 'Chưa có'),
          ],
        );
      case 'RECEPTIONIST':
        final profile = user.profile as ReceptionistProfile?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Thông tin Nhân viên'),
            _buildInfoTile(icon: Icons.badge, title: 'Mã nhân viên', subtitle: profile?.employeeId ?? 'Chưa có'),
            _buildInfoTile(icon: Icons.calendar_today_outlined, title: 'Ngày vào làm', subtitle: profile != null ? DateFormat.yMd('vi_VN').format(profile.startDate) : 'Chưa có'),
          ],
        );
      default: // Cho Admin hoặc các vai trò khác không có profile
        return const SizedBox.shrink(); // Trả về widget rỗng
    }
  }

  // Widget helper để tạo tiêu đề cho mỗi phần
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // Widget helper để tạo mỗi dòng thông tin
  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }
}