
// lib/screens/doctor/encounter_screen.dart
// lib/screens/doctor/encounter_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/models/appointment.dart';
import 'package:hospital_app/models/medicine.dart';
import 'package:hospital_app/models/user_account.dart';
import 'package:hospital_app/providers/appointments_provider.dart';
import 'package:hospital_app/providers/encounter_provider.dart';
import 'package:hospital_app/providers/medicine_provider.dart';
import 'package:hospital_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:hospital_app/models/service.dart';
import 'package:hospital_app/providers/doctor_provider.dart';

// ==================== UI helpers ====================
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;
  final EdgeInsetsGeometry? padding;
  const _SectionCard({
    required this.title,
    required this.child,
    required this.icon,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary.withOpacity(.1),
                  child: Icon(icon, size: 16, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  const _ChipLabel({required this.label, required this.icon, this.color, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = (color ?? scheme.primary).withOpacity(.08);
    final fg = color ?? scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14, color: fg), const SizedBox(width: 6), Text(label, style: TextStyle(color: fg))],
      ),
    );
  }
}

// ==================== Data helpers ====================
// <<< THAY ĐỔI 1: CẬP NHẬT PRESCRIPTIONITEMSTATE >>>
class PrescriptionItemState {
  Medicine? selectedMedicine;
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController nameDisplayController = TextEditingController();
  // Thêm controller mới để hiển thị tồn kho
  final TextEditingController stockDisplayController = TextEditingController();

  void dispose() {
    dosageController.dispose();
    quantityController.dispose();
    nameDisplayController.dispose();
    stockDisplayController.dispose(); // Nhớ dispose
  }
}

class EncounterScreen extends ConsumerStatefulWidget {
  final Appointment appointment;
  const EncounterScreen({required this.appointment, Key? key}) : super(key: key);

  @override
  ConsumerState<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends ConsumerState<EncounterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescriptionNotesController = TextEditingController();

  final List<PrescriptionItemState> _prescriptionItems = [PrescriptionItemState()];
  final List<Service> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    // Không cần `addPostFrameCallback` vì chúng ta không cần `ref` ở đây
    _prefillServicesFromAppointment();
  }
  void _prefillServicesFromAppointment() {
    final appointment = widget.appointment;
    
    // Logic mới: Lấy trực tiếp danh sách dịch vụ từ appointment
    if (appointment.services.isNotEmpty) {
      setState(() {
        // Thêm tất cả các dịch vụ đã đăng ký trước vào danh sách đã chọn
        _selectedServices.addAll(appointment.services);
      });
    }
  }

  
  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _prescriptionNotesController.dispose();
    for (var item in _prescriptionItems) {
      item.dispose();
    }
    super.dispose();
  }
  

  void _addMedicine() => setState(() => _prescriptionItems.add(PrescriptionItemState()));

  void _removeMedicine(int index) {
    if (_prescriptionItems.length > 1) {
      setState(() {
        _prescriptionItems[index].dispose();
        _prescriptionItems.removeAt(index);
      });
    }
  }

  Future<void> _showMedicineSearchDialog(BuildContext context, PrescriptionItemState itemState) async {
    final selectedMedicine = await showDialog<Medicine?>(
      context: context,
      builder: (dialogContext) => const MedicineSearchDialog(),
    );
    if (selectedMedicine != null) {
      setState(() {
        itemState.selectedMedicine = selectedMedicine;
        itemState.nameDisplayController.text = selectedMedicine.name;
        // Cập nhật text cho ô tồn kho
        itemState.stockDisplayController.text = selectedMedicine.stockQuantity.toString();
      });
    }
  }

  //Hàm show dịch vụ của bác sĩ
  Future<void> _showServiceSelectionDialog() async {
    // Lấy ID của bác sĩ đang khám từ appointment
    final doctorId = widget.appointment.doctor.id;
    // Lấy danh sách dịch vụ của bác sĩ đó
    final servicesForDoctor = await ref.read(servicesForDoctorProvider(doctorId).future);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        // Dùng StatefulWidget để quản lý trạng thái chọn trong dialog
        return _ServiceSelectionDialog(
          availableServices: servicesForDoctor,
          initialSelectedServices: _selectedServices,
          onSelectionChanged: (selected) {
            setState(() {
              _selectedServices.clear();
              _selectedServices.addAll(selected);
            });
          },
        );
      },
    );
  }

  // <<< THAY ĐỔI 2: CẬP NHẬT LOGIC SUBMIT >>>
  Future<void> _submitAndComplete() async {
    if (!_formKey.currentState!.validate()) return;

    // --- BƯỚC KIỂM TRA TỒN KHO PHÍA CLIENT ---
    for (var item in _prescriptionItems) {
      if (item.selectedMedicine != null) {
        final quantityToPrescribe = int.tryParse(item.quantityController.text.trim()) ?? 0;
        if (quantityToPrescribe > item.selectedMedicine!.stockQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không đủ thuốc "${item.selectedMedicine!.name}". Tồn kho: ${item.selectedMedicine!.stockQuantity}'),
              backgroundColor: Colors.orange,
            ),
          );
          return; // Dừng lại nếu không đủ thuốc
        }
      }
    }
    
    final itemsPayload = _prescriptionItems
        .where((item) => item.selectedMedicine != null)
        .map((item) => {
              'medicine': item.selectedMedicine!.id,
              'dosage': item.dosageController.text.trim(),
              'quantity': int.tryParse(item.quantityController.text.trim()) ?? 1,
            })
        .toList();
    final serviceIdsPayload = _selectedServices.map((s) => s.id).toList();
    
    try {
      await ref.read(encounterCreationProvider.notifier).createEncounter(
            appointmentId: widget.appointment.id,
            symptoms: _symptomsController.text.trim(),
            diagnosis: _diagnosisController.text.trim(),
            prescriptionItems: itemsPayload,
            prescriptionNotes: _prescriptionNotesController.text.trim(),
            serviceIds: serviceIdsPayload,
          );

      // Chờ provider xử lý xong và kiểm tra lỗi
      // Dùng future để đợi state thay đổi
      await ref.read(encounterCreationProvider.future);

      // Nếu không có lỗi, tiếp tục hoàn thành
      await ref.read(doctorAppointmentsProvider.notifier).completeAppointment(widget.appointment.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu bệnh án và hoàn thành cuộc hẹn!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
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
    final appointment = widget.appointment;
    final doctorDetailState = ref.watch(userDetailProvider(appointment.doctor.id));
    final patientDetailState = ref.watch(userDetailProvider(appointment.patient.id));

    ref.listen<AsyncValue<void>>(encounterCreationProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu bệnh án: ${next.error}'), backgroundColor: Colors.red),
        );
      }
    });

    final isSaving = ref.watch(encounterCreationProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khám cho ${appointment.patient.fullName}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              DateFormat.yMMMd('vi_VN').add_Hm().format(appointment.appointmentTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : _submitAndComplete,
            icon: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('LƯU BỆNH ÁN & HOÀN THÀNH KHÁM'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: doctorDetailState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Lỗi tải thông tin bác sĩ: $e')),
          data: (doctorUser) => patientDetailState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Lỗi tải thông tin bệnh nhân: $e')),
            data: (patientUser) {
              final doctorProfile = doctorUser.profile as DoctorProfile?;
              final patientProfile = patientUser.profile as PatientProfile?;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                children: [
                  _SectionCard(
                    title: 'Thông tin Lịch hẹn',
                    icon: Icons.event_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ChipLabel(
                          label: DateFormat.yMMMd('vi_VN').add_Hm().format(appointment.appointmentTime),
                          icon: Icons.schedule,
                        ),
                        _ChipLabel(
                          label: doctorProfile?.specialtyName ?? 'Chưa xác định',
                          icon: Icons.medical_services_outlined,
                        ),
                        _ChipLabel(
                          label: 'Lý do: ${appointment.reason}',
                          icon: Icons.notes_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        if (patientProfile?.allergies != null && (patientProfile!.allergies?.isNotEmpty ?? false))
                          _ChipLabel(
                            label: 'Dị ứng: ${patientProfile!.allergies!}',
                            icon: Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ),
                  _SectionCard(
                    title: 'Nhập thông tin Bệnh án',
                    icon: Icons.article_outlined,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _symptomsController,
                          decoration: const InputDecoration(
                            labelText: 'Triệu chứng',
                            hintText: 'VD: sốt, ho khan, đau đầu…',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                          validator: (v) => v!.trim().isEmpty ? 'Vui lòng nhập triệu chứng' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _diagnosisController,
                          decoration: const InputDecoration(
                            labelText: 'Chẩn đoán',
                            hintText: 'VD: Cúm A, Viêm họng cấp…',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                          validator: (v) => v!.trim().isEmpty ? 'Vui lòng nhập chẩn đoán' : null,
                        ),
                      ],
                    ),
                  ),
                  _SectionCard(
                    title: 'Dịch vụ đã thực hiện',
                    icon: Icons.receipt_long_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedServices.isEmpty)
                          const Text('Chưa có dịch vụ nào được chọn.'),
                        
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedServices.map((service) {
                            return Chip(
                              label: Text(service.name),
                              labelStyle: const TextStyle(color: Colors.white),
                              backgroundColor: Theme.of(context).primaryColor,
                              onDeleted: () {
                                setState(() {
                                  _selectedServices.remove(service);
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 8),
                        
                        Center(
                          child: TextButton.icon(
                            onPressed: _showServiceSelectionDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm/Sửa dịch vụ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SectionCard(
                    title: 'Đơn thuốc',
                    icon: Icons.local_pharmacy_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _prescriptionNotesController,
                          decoration: const InputDecoration(
                            labelText: 'Ghi chú/Dặn dò',
                            hintText: 'Cách dùng, thời điểm uống, lưu ý…',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Danh sách thuốc', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            TextButton.icon(
                              onPressed: _addMedicine,
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Thêm thuốc'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _prescriptionItems.length,
                          itemBuilder: (context, index) {
                            final itemState = _prescriptionItems[index];
                            return Card(
                              elevation: 0,
                              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.35),
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            controller: itemState.nameDisplayController,
                                            decoration: const InputDecoration(
                                              labelText: 'Tên thuốc',
                                              hintText: 'Nhấn để chọn',
                                              prefixIcon: Icon(Icons.search),
                                            ),
                                            readOnly: true,
                                            onTap: () => _showMedicineSearchDialog(context, itemState),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 3,
                                          child: TextFormField(
                                            controller: itemState.dosageController,
                                            decoration: const InputDecoration(
                                              labelText: 'Liều lượng',
                                              hintText: 'VD: 500mg',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                          tooltip: 'Xóa',
                                          onPressed: () => _removeMedicine(index),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: itemState.quantityController,
                                            decoration: const InputDecoration(
                                              labelText: 'Số lượng kê',
                                              hintText: 'SL',
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            controller: itemState.stockDisplayController,
                                            decoration: const InputDecoration(
                                              labelText: 'Tồn kho',
                                              prefixIcon: Icon(Icons.inventory_2_outlined, size: 18),
                                            ),
                                            readOnly: true,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== Medicine Search Dialog (UPDATED) ====================
// <<< THAY ĐỔI 3: CẬP NHẬT HOÀN TOÀN DIALOG TÌM KIẾM THUỐC >>>
class MedicineSearchDialog extends ConsumerStatefulWidget {
  const MedicineSearchDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicineSearchDialog> createState() => _MedicineSearchDialogState();
}

class _MedicineSearchDialogState extends ConsumerState<MedicineSearchDialog> {
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _searchQuery = query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Luôn gọi provider với query, dù là rỗng, để hiển thị danh sách ban đầu
    final searchResults = ref.watch(medicineSearchProvider(_searchQuery));

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: Row(
        children: const [
          Icon(Icons.local_pharmacy_outlined, size: 20),
          SizedBox(width: 8),
          Text('Tìm kiếm thuốc'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nhập tên thuốc…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.25),
                  child: searchResults.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Lỗi: $e')),
                    data: (medicines) {
                      if (medicines.isEmpty && _searchQuery.isNotEmpty) {
                        return const Center(child: Text('Không tìm thấy thuốc.'));
                      }
                      return ListView.separated(
                        itemCount: medicines.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final medicine = medicines[index];
                          final isOutOfStock = medicine.stockQuantity <= 0;
                          final stockColor = isOutOfStock ? Colors.red : Colors.green;

                          return ListTile(
                            enabled: !isOutOfStock, // Vô hiệu hóa nếu hết hàng
                            leading: Icon(
                              Icons.medication_outlined,
                              color: isOutOfStock ? Colors.grey : Theme.of(context).primaryColor,
                            ),
                            title: Text(
                              medicine.name,
                              style: TextStyle(
                                decoration: isOutOfStock ? TextDecoration.lineThrough : null,
                                color: isOutOfStock ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Text('Đơn vị: ${medicine.unit}'),
                            trailing: Text(
                              'Tồn: ${medicine.stockQuantity}',
                              style: TextStyle(color: stockColor, fontWeight: FontWeight.bold),
                            ),
                            onTap: () => Navigator.of(context).pop(medicine),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng')),
      ],
    );
  }
}
class _ServiceSelectionDialog extends StatefulWidget {
  final List<Service> availableServices;
  final List<Service> initialSelectedServices;
  final ValueChanged<List<Service>> onSelectionChanged;

  const _ServiceSelectionDialog({
    required this.availableServices,
    required this.initialSelectedServices,
    required this.onSelectionChanged,
  });

  @override
  State<_ServiceSelectionDialog> createState() => _ServiceSelectionDialogState();
}

class _ServiceSelectionDialogState extends State<_ServiceSelectionDialog> {
  late final Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelectedServices.map((s) => s.id).toSet();
  }

  void _onConfirm() {
    final selectedServices = widget.availableServices
        .where((s) => _selectedIds.contains(s.id))
        .toList();
    widget.onSelectionChanged(selectedServices);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn dịch vụ đã thực hiện'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.availableServices.length,
          itemBuilder: (context, index) {
            final service = widget.availableServices[index];
            final isSelected = _selectedIds.contains(service.id);
            return CheckboxListTile(
              title: Text(service.name),
              subtitle: Text('Giá: ${service.price}'),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedIds.add(service.id);
                  } else {
                    _selectedIds.remove(service.id);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        ElevatedButton(onPressed: _onConfirm, child: const Text('Xác nhận')),
      ],
    );
  }
}