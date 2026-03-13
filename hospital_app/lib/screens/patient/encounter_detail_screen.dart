

// import 'package:flutter/material.dart';
// import 'package:hospital_app/models/encounter.dart';
// import 'package:intl/intl.dart';

// /// EncounterDetailScreen – Medical theme (green), color-scheme aligned
// /// - No hard-coded Colors.* (use Theme.of(context).colorScheme)
// /// - Avatar removed in header as requested
// /// - Logic/UI preserved
// class EncounterDetailScreen extends StatelessWidget {
//   final Encounter encounter;
//   const EncounterDetailScreen({required this.encounter, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Chi tiết bệnh án', style: TextStyle(fontWeight: FontWeight.w700)),
//             const SizedBox(height: 2),
//             Text(
//               DateFormat.yMMMd('vi_VN').add_Hm().format(encounter.appointmentTime),
//               style: theme.textTheme.bodySmall,
//             ),
//           ],
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//         children: [
//           // ===== Header banner (no avatar)
//           _BannerHeader(
//             doctorName: encounter.doctorName,
//             reason: encounter.reasonWhy,
//             scheme: scheme,
//           ),
//           const SizedBox(height: 12),

//           // ===== General info
//           _SectionCard(
//             title: 'Thông tin chung',
//             icon: Icons.info_outline,
//             child: Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _PillChip(
//                   icon: Icons.schedule,
//                   label: 'Ngày khám: ${DateFormat.yMMMd('vi_VN').add_Hm().format(encounter.appointmentTime)}',
//                   scheme: scheme,
//                 ),
//                 if ((encounter as dynamic).specialtyName != null)
//                   _PillChip(
//                     icon: Icons.medical_services_outlined,
//                     label: 'Chuyên khoa: ${(encounter as dynamic).specialtyName}',
//                     scheme: scheme,
//                   ),
//                 _PillChip(
//                   icon: Icons.notes_outlined,
//                   label: 'Lý do: ${encounter.reasonWhy}',
//                   scheme: scheme,
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ===== Clinical notes
//           _SectionCard(
//             title: 'Chi tiết bệnh án',
//             icon: Icons.article_outlined,
//             child: Column(
//               children: [
//                 _InfoTile(
//                   title: 'Triệu chứng',
//                   content: encounter.symptoms,
//                   leading: Icons.coronavirus_outlined,
//                   scheme: scheme,
//                 ),
//                 const SizedBox(height: 10),
//                 _InfoTile(
//                   title: 'Chẩn đoán của bác sĩ',
//                   content: encounter.diagnosis,
//                   leading: Icons.local_hospital_outlined,
//                   scheme: scheme,
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ===== Prescriptions
//           _SectionCard(
//             title: 'Đơn thuốc',
//             icon: Icons.local_pharmacy_outlined,
//             child: (encounter.prescriptions.isEmpty ||
//                     encounter.prescriptions.every((p) => p.items.isEmpty))
//                 ? _EmptyState(text: 'Không có đơn thuốc cho lần khám này.', scheme: scheme)
//                 : Column(
//                     children: encounter.prescriptions.map((p) {
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         decoration: BoxDecoration(
//                           color: scheme.surfaceVariant.withOpacity(.28),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: scheme.outlineVariant.withOpacity(.25)),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (p.notes != null && p.notes!.isNotEmpty) ...[
//                                 Row(
//                                   children: [
//                                     Icon(Icons.note_alt_outlined, size: 18, color: scheme.secondary),
//                                     const SizedBox(width: 6),
//                                     Text('Ghi chú của bác sĩ', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(p.notes!, style: const TextStyle(height: 1.5)),
//                                 const SizedBox(height: 12),
//                               ],
//                               _PrescriptionTable(items: p.items, scheme: scheme),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hospital_app/models/encounter.dart';
import 'package:intl/intl.dart';

class EncounterDetailScreen extends StatelessWidget {
  final Encounter encounter;
  const EncounterDetailScreen({required this.encounter, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chi tiết bệnh án', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              DateFormat.yMMMd('vi_VN').add_Hm().format(encounter.appointmentTime.toLocal()), // Chuyển sang giờ địa phương
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _BannerHeader(
            doctorName: encounter.doctorName,
            reason: encounter.reasonWhy,
            scheme: scheme,
          ),
          const SizedBox(height: 12),

          _SectionCard(
            title: 'Thông tin chung',
            icon: Icons.info_outline,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PillChip(
                  icon: Icons.schedule,
                  label: 'Ngày khám: ${DateFormat.yMMMd('vi_VN').add_Hm().format(encounter.appointmentTime.toLocal())}',
                  scheme: scheme,
                ),
                if (encounter.specialtyName != null)
                  _PillChip(
                    icon: Icons.medical_services_outlined,
                    label: 'Chuyên khoa: ${encounter.specialtyName}',
                    scheme: scheme,
                  ),
                _PillChip(
                  icon: Icons.notes_outlined,
                  label: 'Lý do: ${encounter.reasonWhy}',
                  scheme: scheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _SectionCard(
            title: 'Chi tiết bệnh án',
            icon: Icons.article_outlined,
            child: Column(
              children: [
                _InfoTile(
                  title: 'Triệu chứng',
                  content: encounter.symptoms,
                  leading: Icons.coronavirus_outlined,
                  scheme: scheme,
                ),
                const SizedBox(height: 10),
                _InfoTile(
                  title: 'Chẩn đoán của bác sĩ',
                  content: encounter.diagnosis,
                  leading: Icons.local_hospital_outlined,
                  scheme: scheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==========================================================
          // <<< === THÊM MỚI: PHẦN HIỂN THỊ DỊCH VỤ ĐÃ SỬ DỤNG === >>>
          // ==========================================================
          // Chỉ hiển thị nếu có dịch vụ
          if (encounter.servicesPerformed.isNotEmpty)
            _SectionCard(
              title: 'Dịch vụ đã thực hiện',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: encounter.servicesPerformed.map((service) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: scheme.secondary.withOpacity(0.1),
                      child: Icon(Icons.design_services_outlined, color: scheme.secondary),
                    ),
                    title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      '${NumberFormat.decimalPattern('vi_VN').format(int.tryParse(service.price) ?? 0)} VNĐ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: scheme.secondary),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          if (encounter.servicesPerformed.isNotEmpty)
            const SizedBox(height: 12),


          // ===== Prescriptions
          _SectionCard(
            title: 'Đơn thuốc',
            icon: Icons.local_pharmacy_outlined,
            child: (encounter.prescriptions.isEmpty ||
                    encounter.prescriptions.every((p) => p.items.isEmpty))
                ? _EmptyState(text: 'Không có đơn thuốc cho lần khám này.', scheme: scheme)
                : Column(
                    children: encounter.prescriptions.map((p) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceVariant.withOpacity(.28),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: scheme.outlineVariant.withOpacity(.25)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (p.notes != null && p.notes!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(Icons.note_alt_outlined, size: 18, color: scheme.secondary),
                                    const SizedBox(width: 6),
                                    Text('Ghi chú của bác sĩ', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(p.notes!, style: const TextStyle(height: 1.5)),
                                const SizedBox(height: 12),
                              ],
                              _PrescriptionTable(items: p.items, scheme: scheme),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// =============== Reusable widgets ===============
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: scheme.primary.withOpacity(.1),
                  child: Icon(icon, size: 16, color: scheme.primary),
                ),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  const _PillChip({required this.icon, required this.label, required this.scheme});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String content;
  final IconData leading;
  final ColorScheme scheme;
  const _InfoTile({required this.title, required this.content, required this.leading, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: scheme.surfaceVariant.withOpacity(.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: scheme.primary.withOpacity(.12),
          child: Icon(leading, color: scheme.primary, size: 18),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: scheme.primary)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(content, style: const TextStyle(height: 1.5)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  final ColorScheme scheme;
  const _EmptyState({required this.text, required this.scheme});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.25)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: scheme.primary.withOpacity(.6)),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: scheme.onSurface.withOpacity(.7))),
        ],
      ),
    );
  }
}

class _BannerHeader extends StatelessWidget {
  final String doctorName;
  final String reason;
  final ColorScheme scheme;
  const _BannerHeader({required this.doctorName, required this.reason, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary.withOpacity(.10), scheme.primary.withOpacity(.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.25)),
      ),
      child: Row(
        children: [
          // No avatar – only texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bác sĩ khám: $doctorName',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Lý do: $reason',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _PillChip(icon: Icons.verified_outlined, label: 'Đã khám', scheme: scheme),
        ],
      ),
    );
  }
}

class _PrescriptionTable extends StatelessWidget {
  final List<PrescriptionItem> items;
  final ColorScheme scheme;
  const _PrescriptionTable({required this.items, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return DataTableTheme(
      data: DataTableThemeData(
        headingRowColor: MaterialStatePropertyAll(scheme.primary.withOpacity(.08)),
        dataRowColor: MaterialStatePropertyAll(scheme.surfaceVariant.withOpacity(.18)),
        dividerThickness: .8,
        horizontalMargin: 8,
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      child: DataTable(
        columnSpacing: 16,
        headingRowHeight: 40,
        columns: const [
          DataColumn(label: Expanded(child: Text('Tên thuốc'))),
          DataColumn(label: Expanded(child: Text('Liều lượng'))),
          DataColumn(label: Text('SL'), numeric: true),
        ],
        rows: items
            .map((it) => DataRow(cells: [
                  DataCell(Row(children: [
                    const Icon(Icons.medication_outlined, size: 18),
                    const SizedBox(width: 6),
                    Flexible(child: Text(it.medicineDetails.name)),
                  ])),
                  DataCell(Text(it.dosage)),
                  DataCell(Text(it.quantity.toString())),
                ]))
            .toList(),
      ),
    );
  }
}
