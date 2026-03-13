// lib/screens/admin/admin_medicine_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/medicine.dart';
import 'package:hospital_app/providers/medicine_provider.dart';

class AdminMedicineManagementScreen extends ConsumerWidget {
  const AdminMedicineManagementScreen({super.key});

  // Dialog cho chức năng NHẬP KHO
  void _showAddStockDialog(BuildContext context, WidgetRef ref, Medicine medicine) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nhập kho: ${medicine.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantityController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Số lượng nhập thêm (*)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Không được để trống';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Số lượng phải là số dương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Ghi chú (VD: Lô hàng mới)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              final quantity = int.parse(quantityController.text.trim());
              final notes = notesController.text.trim();

              await ref.read(adminMedicineListProvider.notifier).addStock(medicine.id, quantity, notes: notes);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  // Dialog cho chức năng XUẤT KHO
  void _showRemoveStockDialog(BuildContext context, WidgetRef ref, Medicine medicine) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xuất kho: ${medicine.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Số lượng tồn hiện tại: ${medicine.stockQuantity}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Số lượng xuất (*)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Không được để trống';
                  final qty = int.parse(value);
                  if (qty <= 0) return 'Số lượng phải > 0';
                  if (qty > medicine.stockQuantity) return 'Vượt quá số lượng tồn kho';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Lý do xuất kho (*)'),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập lý do' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              final quantity = int.parse(quantityController.text.trim());
              final notes = notesController.text.trim();
              
              await ref.read(adminMedicineListProvider.notifier).removeStock(
                id: medicine.id,
                quantity: quantity,
                notes: notes,
              );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Xác nhận xuất'),
          ),
        ],
      ),
    );
  }

  // Dialog để Thêm hoặc Sửa thông tin thuốc
  void _showEditDialog(BuildContext context, WidgetRef ref, {Medicine? medicine}) {
    showDialog(
      context: context,
      builder: (context) => _MedicineEditDialog(medicine: medicine),
    );
  }
  
  // Dialog để xác nhận Xóa
  void _showDeleteDialog(BuildContext context, WidgetRef ref, Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${medicine.name}" khỏi danh mục?\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
                await ref.read(adminMedicineListProvider.notifier).deleteMedicine(medicine.id);
                if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(adminMedicineListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Kho thuốc'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, ref),
        tooltip: 'Thêm thuốc mới',
        child: const Icon(Icons.add),
      ),
      body: medicinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
        data: (medicines) {
          if (medicines.isEmpty) {
            return const Center(child: Text('Chưa có thuốc nào trong kho.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(adminMedicineListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Chừa không gian cho FAB
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Đơn vị: ${medicine.unit}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tồn: ${medicine.stockQuantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                               if (value == 'add') {
                                _showAddStockDialog(context, ref, medicine);
                              } else if (value == 'remove') {
                                _showRemoveStockDialog(context, ref, medicine);
                              } else if (value == 'edit') {
                                _showEditDialog(context, ref, medicine: medicine);
                              } else if (value == 'delete') {
                                _showDeleteDialog(context, ref, medicine);
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: ListTile(leading: Icon(Icons.edit_outlined, color: Colors.blue), title: Text('Sửa thông tin thuốc')),
                              ),
                               const PopupMenuDivider(),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Xóa thuốc')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

// Dialog Thêm/Sửa thuốc
class _MedicineEditDialog extends ConsumerStatefulWidget {
  final Medicine? medicine;
  const _MedicineEditDialog({this.medicine});

  @override
  ConsumerState<_MedicineEditDialog> createState() => _MedicineEditDialogState();
}

class _MedicineEditDialogState extends ConsumerState<_MedicineEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _initialStockController = TextEditingController(text: '0');

  bool get isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.medicine!.name;
      _unitController.text = widget.medicine!.unit;
      _descriptionController.text = widget.medicine!.description ??'';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    _initialStockController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final notifier = ref.read(adminMedicineListProvider.notifier);
    
    try {
      if (isEditing) {
        await notifier.updateMedicine(
          id: widget.medicine!.id,
          name: _nameController.text.trim(),
          unit: _unitController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      } else {
        await notifier.addMedicine(
          name: _nameController.text.trim(),
          unit: _unitController.text.trim(),
          description: _descriptionController.text.trim(),
          initialStock: int.tryParse(_initialStockController.text.trim()) ?? 0,
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
      title: Text(isEditing ? 'Sửa thông tin Thuốc' : 'Thêm Thuốc mới'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên thuốc (*)'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Đơn vị (Viên, Lọ...) (*)'),
                 validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả (không bắt buộc)'),
                maxLines: 2,
              ),
              if (!isEditing)
                TextFormField(
                  controller: _initialStockController,
                  decoration: const InputDecoration(labelText: 'Số lượng ban đầu'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        ElevatedButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}