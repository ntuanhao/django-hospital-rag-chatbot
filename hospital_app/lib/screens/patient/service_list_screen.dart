// lib/screens/patient/service_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/service.dart';
import 'package:hospital_app/models/specialty.dart';
import 'package:hospital_app/providers/service_provider.dart';
import 'package:hospital_app/providers/specialty_provider.dart'; // <<< THÊM IMPORT
import 'package:intl/intl.dart';

class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({super.key});

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Gọi cả hai provider để lấy dữ liệu
    final servicesAsync = ref.watch(serviceListProvider(null));
    final specialtiesAsync = ref.watch(specialtyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả Dịch vụ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                labelText: 'Tìm kiếm dịch vụ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          Expanded(
            // Dùng một provider để gộp kết quả từ 2 provider trên
            child: ref.watch(_groupedServicesProvider(_searchQuery)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Lỗi: $error')),
              data: (groupedData) {
                if (groupedData.isEmpty) {
                  return const Center(child: Text('Không tìm thấy dịch vụ nào.'));
                }

                // ListView.builder để xây dựng danh sách các nhóm
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: groupedData.length,
                  itemBuilder: (context, index) {
                    final group = groupedData[index];
                    return _ServiceGroup(
                      specialty: group.specialty, 
                      services: group.services
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

// ============== CÁC WIDGET MỚI ĐỂ HIỂN THỊ GOM NHÓM ==============

// Một record để chứa dữ liệu đã được gom nhóm
typedef ServiceGroup = ({Specialty specialty, List<Service> services});

// Provider mới, chỉ dùng trong file này, để xử lý logic gom nhóm
final _groupedServicesProvider = FutureProvider.autoDispose.family<List<ServiceGroup>, String>((ref, searchQuery) async {
  // Lấy dữ liệu từ hai provider gốc
  final allServices = await ref.watch(serviceListProvider(null).future);
  final allSpecialties = await ref.watch(specialtyListProvider.future);

  // Lọc các dịch vụ trước dựa trên query tìm kiếm
  final filteredServices = allServices.where((service) {
    return service.name.toLowerCase().contains(searchQuery);
  }).toList();
  
  final List<ServiceGroup> result = [];

  // Lặp qua từng chuyên khoa để gom nhóm
  for (final specialty in allSpecialties) {
    // Tìm tất cả dịch vụ thuộc chuyên khoa này
    final servicesInGroup = filteredServices.where(
      (service) => service.specialtyIds.contains(specialty.id)
    ).toList();

    // Chỉ thêm vào kết quả nếu nhóm đó có dịch vụ
    if (servicesInGroup.isNotEmpty) {
      result.add((specialty: specialty, services: servicesInGroup));
    }
  }

  // Tìm các dịch vụ không thuộc chuyên khoa nào
  final uncategorizedServices = filteredServices.where(
    (service) => service.specialtyIds.isEmpty
  ).toList();
  
  if (uncategorizedServices.isNotEmpty) {
     result.add((
        specialty: Specialty(id: -1, name: 'Dịch vụ khác'), // Chuyên khoa "ảo"
        services: uncategorizedServices
     ));
  }
  
  return result;
});


// Widget để hiển thị một nhóm (Chuyên khoa + danh sách dịch vụ)
class _ServiceGroup extends StatelessWidget {
  final Specialty specialty;
  final List<Service> services;
  const _ServiceGroup({required this.specialty, required this.services});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề của nhóm (tên chuyên khoa)
          Text(
            specialty.name.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          // Danh sách các dịch vụ trong nhóm
          ...services.map((service) => _ServiceListItem(service: service)),
        ],
      ),
    );
  }
}

// Widget để hiển thị một item dịch vụ (giống ListTile cũ)
class _ServiceListItem extends StatelessWidget {
  final Service service;
  const _ServiceListItem({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.medical_services_outlined, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${NumberFormat.decimalPattern('vi_VN').format(int.tryParse(service.price) ?? 0)} VNĐ',
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Điều hướng
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chức năng xem bác sĩ theo dịch vụ sẽ được phát triển.'))
          );
        },
      ),
    );
  }
}