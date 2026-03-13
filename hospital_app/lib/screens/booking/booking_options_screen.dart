// lib/screens/booking/booking_options_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingOptionsScreen extends StatelessWidget {

  const BookingOptionsScreen({ Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt Lịch Hẹn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Bạn muốn tìm kiếm theo cách nào?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildOptionCard(
              context: context,
              icon: Icons.medical_services_outlined,
              title: 'Tìm theo Chuyên khoa',
              subtitle: 'Phù hợp khi bạn chưa biết khám bác sĩ nào.',
              onTap: () {
                // Điều hướng đến màn hình chọn chuyên khoa
                context.push('/patient/home/select-specialty');
              },
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context: context,
              icon: Icons.person_search_outlined,
              title: 'Tìm theo Tên Bác sĩ',
              subtitle: 'Dành cho khi bạn muốn khám một bác sĩ cụ thể.',
              onTap: () {
                // Điều hướng đến màn hình tìm kiếm bác sĩ
                context.push('/patient/home/search-doctor');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo giao diện cho mỗi lựa chọn
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}