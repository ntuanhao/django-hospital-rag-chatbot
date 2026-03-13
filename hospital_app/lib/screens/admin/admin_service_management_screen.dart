// lib/screens/admin/admin_service_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/service.dart';
import 'package:hospital_app/models/specialty.dart';
import 'package:hospital_app/providers/service_provider.dart'; 
import 'package:hospital_app/providers/specialty_provider.dart';

class AdminServiceManagementScreen extends ConsumerWidget {
  const AdminServiceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(adminServiceListProvider);
    // Đồng thời lấy cả danh sách chuyên khoa để truyền vào dialog
    final specialtiesAsync = ref.watch(specialtyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Dịch vụ'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Khi thêm mới, chỉ hiển thị dialog nếu đã tải xong danh sách chuyên khoa
          specialtiesAsync.whenData((specialties) {
            _showEditDialog(context, ref, specialties: specialties);
          });
        },
        child: const Icon(Icons.add),
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
        data: (services) {
          if (services.isEmpty) {
            return const Center(child: Text('Chưa có dịch vụ nào.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(adminServiceListProvider.future),
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ListTile(
                  title: Text(service.name),
                  subtitle: Text('Giá: ${service.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () {
                          specialtiesAsync.whenData((specialties) {
                            _showEditDialog(context, ref, service: service, specialties: specialties);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, ref, service),
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc chắn muốn xóa dịch vụ "${service.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(adminServiceListProvider.notifier).deleteService(service.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, {Service? service, required List<Specialty> specialties}) {
    showDialog(
      context: context,
      builder: (context) => _ServiceEditDialog(
        service: service,
        allSpecialties: specialties,
      ),
    );
  }
}

// Widget dialog riêng để quản lý state của chính nó
class _ServiceEditDialog extends ConsumerStatefulWidget {
  final Service? service;
  final List<Specialty> allSpecialties;

  const _ServiceEditDialog({this.service, required this.allSpecialties});

  @override
  ConsumerState<_ServiceEditDialog> createState() => _ServiceEditDialogState();
}

class _ServiceEditDialogState extends ConsumerState<_ServiceEditDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  late Set<int> _selectedSpecialtyIds;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.service?.name ?? '';
    _priceController.text = widget.service?.price ?? '';
    _selectedSpecialtyIds = widget.service?.specialtyIds.toSet() ?? {};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    if (name.isEmpty || price.isEmpty) return;

    final notifier = ref.read(adminServiceListProvider.notifier);

    try {
      if (widget.service == null) { // Create
        await notifier.addService(
          name: name,
          price: price,
          specialtyIds: _selectedSpecialtyIds.toList(),
        );
      } else { // Update
        await notifier.updateService(
          id: widget.service!.id,
          name: name,
          price: price,
          specialtyIds: _selectedSpecialtyIds.toList(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.service == null ? 'Thêm Dịch vụ Mới' : 'Sửa Dịch vụ'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên dịch vụ')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Giá'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const Text('Thuộc các Chuyên khoa:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: widget.allSpecialties.map((specialty) {
                final isSelected = _selectedSpecialtyIds.contains(specialty.id);
                return FilterChip(
                  label: Text(specialty.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSpecialtyIds.add(specialty.id);
                      } else {
                        _selectedSpecialtyIds.remove(specialty.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        ElevatedButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}