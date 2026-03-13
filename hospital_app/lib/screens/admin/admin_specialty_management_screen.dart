// lib/screens/admin/admin_specialty_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/specialty.dart';
import 'package:hospital_app/providers/specialty_provider.dart';

class AdminSpecialtyManagementScreen extends ConsumerWidget {
  const AdminSpecialtyManagementScreen({super.key});

  // Hàm hiển thị dialog để Thêm hoặc Sửa
  void _showEditDialog(BuildContext context, WidgetRef ref, {Specialty? specialty}) {
    final isEditing = specialty != null;
    final controller = TextEditingController(text: isEditing ? specialty.name : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Sửa Chuyên khoa' : 'Thêm Chuyên khoa Mới'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Tên chuyên khoa'),
          ),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Lưu'),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                try {
                  if (isEditing) {
                    await ref.read(specialtyListProvider.notifier).updateSpecialty(specialty.id, name);
                  } else {
                    await ref.read(specialtyListProvider.notifier).addSpecialty(name);
                  }
                  if (context.mounted) Navigator.of(context).pop();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm hiển thị dialog xác nhận Xóa
  void _showDeleteDialog(BuildContext context, WidgetRef ref, Specialty specialty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc chắn muốn xóa chuyên khoa "${specialty.name}" không?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
            onPressed: () async {
              try {
                await ref.read(specialtyListProvider.notifier).deleteSpecialty(specialty.id);
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                 if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialtiesAsync = ref.watch(specialtyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Chuyên khoa'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: specialtiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
        data: (specialties) {
          if (specialties.isEmpty) {
            return const Center(child: Text('Chưa có chuyên khoa nào.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(specialtyListProvider.future),
            child: ListView.builder(
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                final specialty = specialties[index];
                return ListTile(
                  title: Text(specialty.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _showEditDialog(context, ref, specialty: specialty),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, ref, specialty),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}