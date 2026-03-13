// lib/widgets/doctor_search_delegate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/doctor_provider.dart'; // <<< SỬ DỤNG PROVIDER CỦA BÁC SĨ

class DoctorSearchDelegate extends SearchDelegate<UserAccount?> {
  final WidgetRef ref;

  DoctorSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Tìm kiếm bác sĩ...'; // Thay đổi nhãn

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Nhập tên hoặc chuyên khoa để tìm kiếm.'));
    }

    // <<< SỬ DỤNG DOCTORLISTPROVIDER >>>
    final filter = (searchQuery: query, specialtyId: null);
    final searchResults = ref.watch(doctorListProvider(filter));
    
    return searchResults.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Lỗi: $e')),
      data: (doctors) {
        if (doctors.isEmpty) {
          return Center(child: Text('Không tìm thấy bác sĩ nào cho "$query"'));
        }
        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            final profile = doctor.profile as DoctorProfile?;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: doctor.avatar != null ? NetworkImage(doctor.avatar!) : null,
                child: doctor.avatar == null ? const Icon(Icons.medical_services_outlined) : null,
              ),
              title: Text('BS. ${doctor.lastName} ${doctor.firstName}'),
              subtitle: Text(profile?.specialtyName ?? 'Chuyên khoa chung'),
              onTap: () {
                // Đóng và trả về bác sĩ đã chọn
                close(context, doctor);
              },
            );
          },
        );
      },
    );
  }
}