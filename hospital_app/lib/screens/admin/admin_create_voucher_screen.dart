// lib/screens/admin/admin_create_voucher_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/models/medicine.dart';
import 'package:hospital_app/providers/medicine_provider.dart';
import 'package:hospital_app/providers/stock_voucher_provider.dart';

// Class để quản lý trạng thái của một dòng trong phiếu
class VoucherItemState {
  Medicine? selectedMedicine;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  void dispose() {
    quantityController.dispose();
    notesController.dispose();
  }
}

class AdminCreateVoucherScreen extends ConsumerStatefulWidget {
  const AdminCreateVoucherScreen({super.key});

  @override
  ConsumerState<AdminCreateVoucherScreen> createState() => _AdminCreateVoucherScreenState();
}

class _AdminCreateVoucherScreenState extends ConsumerState<AdminCreateVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _voucherType = 'STOCK_IN'; // Mặc định là Phiếu Nhập
  
  final List<VoucherItemState> _voucherItems = [VoucherItemState()];

  @override
  void dispose() {
    _reasonController.dispose();
    for (var item in _voucherItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() => setState(() => _voucherItems.add(VoucherItemState()));

  void _removeItem(int index) {
    if (_voucherItems.length > 1) {
      setState(() {
        _voucherItems[index].dispose();
        _voucherItems.removeAt(index);
      });
    }
  }

  Future<void> _showMedicineSearchDialog(VoucherItemState itemState) async {
    final selectedMedicine = await showDialog<Medicine?>(
      context: context,
      builder: (dialogContext) => const _MedicineSearchDialogForVoucher(),
    );
    if (selectedMedicine != null) {
      setState(() {
        itemState.selectedMedicine = selectedMedicine;
      });
    }
  }

  Future<void> _submitVoucher() async {
    if (!_formKey.currentState!.validate()) return;
    if (_voucherItems.any((item) => item.selectedMedicine == null || item.quantityController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thuốc và nhập số lượng cho tất cả các dòng.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final transactionsPayload = _voucherItems.map((item) => {
      'medicine': item.selectedMedicine!.id,
      'quantity': int.parse(item.quantityController.text),
      'notes': item.notesController.text,
    }).toList();

    final success = await ref.read(createVoucherProvider.notifier).createVoucher(
      voucherType: _voucherType,
      reason: _reasonController.text,
      transactions: transactionsPayload,
    );

    if (success && mounted) {
      ref.invalidate(stockVoucherListProvider); // Làm mới danh sách phiếu
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo phiếu thành công!'), backgroundColor: Colors.green),
      );
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${ref.read(createVoucherProvider).error}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createVoucherState = ref.watch(createVoucherProvider);
    final isLoading = createVoucherState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Phiếu Kho'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : _submitVoucher,
          icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('LƯU PHIẾU'),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- THÔNG TIN CHUNG CỦA PHIẾU ---
            DropdownButtonFormField<String>(
              value: _voucherType,
              decoration: const InputDecoration(labelText: 'Loại Phiếu (*)'),
              items: const [
                DropdownMenuItem(value: 'STOCK_IN', child: Text('Phiếu Nhập kho')),
                DropdownMenuItem(value: 'STOCK_OUT', child: Text('Phiếu Xuất kho')),
              ],
              onChanged: (value) => setState(() => _voucherType = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Lý do/Mô tả (*)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập lý do' : null,
            ),
            const Divider(height: 32),

            // --- DANH SÁCH CÁC DÒNG CHI TIẾT ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chi tiết Phiếu', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm dòng'),
                )
              ],
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _voucherItems.length,
              itemBuilder: (context, index) {
                final itemState = _voucherItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Dòng chọn thuốc
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text('${index + 1}', style: Theme.of(context).textTheme.titleLarge),
                          title: Text(itemState.selectedMedicine?.name ?? 'Chưa chọn thuốc'),
                          subtitle: Text('Tồn kho: ${itemState.selectedMedicine?.stockQuantity ?? 'N/A'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _showMedicineSearchDialog(itemState),
                          ),
                        ),
                        // Dòng nhập số lượng và ghi chú
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: itemState.quantityController,
                                decoration: const InputDecoration(labelText: 'Số lượng (*)'),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) => (v == null || v.isEmpty || int.parse(v) <= 0) ? 'SL > 0' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: itemState.notesController,
                                decoration: const InputDecoration(labelText: 'Ghi chú dòng'),
                              ),
                            ),
                            if (_voucherItems.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () => _removeItem(index),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// Dialog tìm kiếm thuốc (tương tự như bên Encounter)
class _MedicineSearchDialogForVoucher extends ConsumerStatefulWidget {
  const _MedicineSearchDialogForVoucher();

  @override
  ConsumerState<_MedicineSearchDialogForVoucher> createState() => _MedicineSearchDialogForVoucherState();
}

class _MedicineSearchDialogForVoucherState extends ConsumerState<_MedicineSearchDialogForVoucher> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Luôn tìm kiếm với query, dù là rỗng
    final searchResults = ref.watch(medicineSearchProvider(_searchQuery));

    return AlertDialog(
      title: const Text('Tìm kiếm thuốc'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nhập tên thuốc'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: searchResults.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Lỗi: $e')),
                data: (medicines) => ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return ListTile(
                      title: Text(medicine.name),
                      subtitle: Text('Tồn kho: ${medicine.stockQuantity}'),
                      onTap: () => Navigator.of(context).pop(medicine),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}