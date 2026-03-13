

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/providers/auth_provider.dart';
import 'package:hospital_app/providers/user_provider.dart';


class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Bảng điều khiển Admin'),
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
              const _HeaderBanner(),
              const SizedBox(height: 16),
              _ServiceGrid(), // Lưới chứa tất cả các nút chức năng
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== Header Chào mừng ==============
class _HeaderBanner extends ConsumerWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final userProfileAsync = ref.watch(userProfileProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A5568), Color(0xFF2D3748)], // Màu xám tối sang trọng
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: userProfileAsync.when(
        data: (user) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, ${user.firstName}!',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chào mừng trở lại bảng điều khiển quản trị.',
              style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, s) => const Text('Chào mừng Admin!', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ============== Lưới Chức năng Chính ==============
class _ServiceGrid extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // Danh sách các chức năng của Admin
    final items = [
      _ServiceItem(
        icon: Icons.manage_accounts_rounded,
        label: 'Người dùng',
        onTap: () => context.push('/admin/dashboard/users'), 
      ),
      _ServiceItem(
        icon: Icons.medical_services_outlined,
        label: 'Chuyên khoa',
        onTap: () => context.push('/admin/dashboard/specialties'), 
      ),
      _ServiceItem(
        icon: Icons.miscellaneous_services_rounded,
        label: 'Dịch vụ',
        onTap: () => context.push('/admin/dashboard/services'),
      ),
      _ServiceItem(
        icon: Icons.inventory_2_outlined,
        label: 'Kho thuốc',
        onTap: () => context.push('/admin/dashboard/medicines'),
      ),
      _ServiceItem(
        icon: Icons.calendar_month_outlined,
        label: 'Lịch hẹn',
        onTap: () => context.push('/admin/dashboard/appointments'),
      ),
       _ServiceItem(
        icon: Icons.schedule_rounded,
        label: 'Thống kê',
        onTap: () => context.push('/admin/dashboard/reports'),
      ),
      _ServiceItem(
        icon: Icons.analytics_outlined,
        label: 'Lịch sử kho',
        onTap: () => context.push('/admin/dashboard/stock-history'),
      ),
      _ServiceItem(
        icon: Icons.receipt_long,
        label: 'Phiếu Kho',
        onTap: () => context.push('/admin/dashboard/vouchers'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cột cho dễ nhìn
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5, // Các ô rộng hơn
      ),
      itemBuilder: (context, i) => _ServiceTile(item: items[i]),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ServiceItem({required this.icon, required this.label, required this.onTap});
}

class _ServiceTile extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 32, color: Theme.of(context).primaryColor),
              const Spacer(),
              Text(
                item.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== Thống kê nhanh (Placeholder) ==============
// class _QuickStats extends StatelessWidget {
//   const _QuickStats();
  
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Thống kê nhanh',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         const Card(
//           child: ListTile(
//             leading: Icon(Icons.people_alt_outlined),
//             title: Text('Tổng số người dùng'),
//             trailing: Text('...'), // TODO: Lấy dữ liệu động
//           ),
//         ),
//         const Card(
//           child: ListTile(
//             leading: Icon(Icons.event_available_outlined),
//             title: Text('Lịch hẹn hôm nay'),
//             trailing: Text('...'), // TODO: Lấy dữ liệu động
//           ),
//         ),
//       ],
//     );
//   }
// }