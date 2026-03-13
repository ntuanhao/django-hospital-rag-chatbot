// lib/screens/receptionist/patient_management_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/patient_provider.dart';
import 'package:go_router/go_router.dart';

class PatientManagementScreen extends ConsumerStatefulWidget {
  const PatientManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends ConsumerState<PatientManagementScreen> {
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Sử dụng debounce để tránh gọi API liên tục khi người dùng gõ
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gọi provider với query hiện tại. Khi query rỗng, nó sẽ lấy tất cả.
    final patientsState = ref.watch(patientListProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Bệnh nhân')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm (tên, SĐT, email...)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: patientsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi tải danh sách: $err')),
              data: (patients) {
                if (patients.isEmpty) {
                  return Center(child: Text(_searchQuery.isEmpty
                      ? 'Chưa có bệnh nhân nào trong hệ thống.'
                      : 'Không tìm thấy bệnh nhân nào khớp với "$_searchQuery".'));
                }
                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: patient.avatar != null
                            ? NetworkImage(patient.avatar!)
                            : null,
                        child: patient.avatar == null
                            ? Text(patient.firstName.isNotEmpty ? patient.firstName[0].toUpperCase() : '?')
                            : null,
                      ),
                      title: Text('${patient.lastName} ${patient.firstName}'),
                      subtitle: Text(patient.phoneNumber ?? patient.email  ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                       context.push('/receptionist/dashboard/manage-patients/${patient.id}');
                      },
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