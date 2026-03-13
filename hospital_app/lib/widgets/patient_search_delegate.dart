// lib/widgets/patient_search_delegate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/patient_provider.dart';

class PatientSearchDelegate extends SearchDelegate<UserAccount?> {
  final WidgetRef ref;

  PatientSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Tìm kiếm bệnh nhân...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Đóng và trả về null
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Khi người dùng nhấn enter, hiển thị kết quả
    return _buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Hiển thị kết quả ngay khi người dùng gõ
    return _buildSuggestions(context);
  }

  Widget _buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Nhập tên, SĐT, hoặc email để tìm kiếm.'));
    }

    final searchResults = ref.watch(patientListProvider(query));

    return searchResults.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Lỗi: $e')),
      data: (patients) {
        if (patients.isEmpty) {
          return Center(child: Text('Không tìm thấy bệnh nhân nào cho "$query"'));
        }
        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: patient.avatar != null ? NetworkImage(patient.avatar!) : null,
                child: patient.avatar == null ? Text(patient.firstName.isNotEmpty ? patient.firstName[0] : '?') : null,
              ),
              title: Text('${patient.lastName} ${patient.firstName}'),
              subtitle: Text(patient.phoneNumber ?? patient.email ),
              onTap: () {
                // Khi chọn một bệnh nhân, đóng màn hình tìm kiếm và trả về bệnh nhân đó
                close(context, patient);
              },
            );
          },
        );
      },
    );
  }
}