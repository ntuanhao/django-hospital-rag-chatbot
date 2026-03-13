// lib/screens/admin/admin_user_list_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

// Helper để map role sang Tiếng Việt
String _translateRole(String role) {
  switch (role) {
    case 'ADMIN': return 'Quản trị viên';
    case 'DOCTOR': return 'Bác sĩ';
    case 'RECEPTIONIST': return 'Lễ tân';
    case 'PATIENT': return 'Bệnh nhân';
    default: return 'Không xác định';
  }
}

class AdminUserListScreen extends ConsumerStatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  ConsumerState<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends ConsumerState<AdminUserListScreen> {
  // State để lưu trữ giá trị filter hiện tại
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedRole;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tạo đối tượng filter từ state
    final filter = UserFilter(searchQuery: _searchQuery, role: _selectedRole);
    // Lắng nghe provider với filter tương ứng
    final usersAsync = ref.watch(adminUserListProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/admin/dashboard/users/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo mới'),
      ),
      body: Column(
        children: [
          // --- Phần Filter và Search ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Tìm theo tên, username, SĐT...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0,
                    children: [
                      FilterChip(
                        label: const Text('Tất cả'),
                        selected: _selectedRole == null,
                        onSelected: (selected) {
                          setState(() => _selectedRole = null);
                        },
                      ),
                      FilterChip(
                        label: const Text('Bác sĩ'),
                        selected: _selectedRole == 'DOCTOR',
                        onSelected: (selected) {
                          setState(() => _selectedRole = selected ? 'DOCTOR' : null);
                        },
                      ),
                      FilterChip(
                        label: const Text('Lễ tân'),
                        selected: _selectedRole == 'RECEPTIONIST',
                        onSelected: (selected) {
                          setState(() => _selectedRole = selected ? 'RECEPTIONIST' : null);
                        },
                      ),
                       FilterChip(
                        label: const Text('Bệnh nhân'),
                        selected: _selectedRole == 'PATIENT',
                        onSelected: (selected) {
                          setState(() => _selectedRole = selected ? 'PATIENT' : null);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Phần Danh sách ---
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Lỗi: $error')),
              data: (users) {
                if (users.isEmpty) {
                  return const Center(child: Text('Không tìm thấy người dùng nào.'));
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(adminUserListProvider(filter).future),
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                          child: user.avatar == null ? Text(user.firstName.isNotEmpty ? user.firstName[0] : '?') : null,
                        ),
                        title: Text(user.fullName),
                        subtitle: Text(user.username),
                        trailing: Chip(
                          label: Text(_translateRole(user.role)),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        ),
                        onTap: () {
                          // TODO: Điều hướng đến trang chi tiết user
                          context.push('/admin/dashboard/users/${user.id}');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}