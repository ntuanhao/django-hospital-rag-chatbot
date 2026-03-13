
// lib/providers/admin_reports_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/models/report_data_point.dart';
import 'package:hospital_app/services/admin_report_service.dart';

// 1. Provider cho Service (không đổi)
final adminReportServiceProvider = Provider.autoDispose((ref) => AdminReportService());

// 2. Enum để quản lý khoảng thời gian (không đổi)
enum ReportTimeRange { week, month }



// Notifier để quản lý trạng thái của TimeRange
class ReportTimeRangeNotifier extends Notifier<ReportTimeRange> {
  @override
  ReportTimeRange build() {
    return ReportTimeRange.week; // Giá trị ban đầu
  }

  void setTimeRange(ReportTimeRange newRange) {
    state = newRange;
  }
}

// Provider cho Notifier
final reportTimeRangeProvider = 
    NotifierProvider<ReportTimeRangeNotifier, ReportTimeRange>(
  ReportTimeRangeNotifier.new,
);


// 3. Provider chính để fetch dữ liệu lịch hẹn (không đổi)
final appointmentsReportProvider = FutureProvider.autoDispose<List<ReportDataPoint>>((ref) {
  final timeRange = ref.watch(reportTimeRangeProvider);
  
  final endDate = DateTime.now();
  final startDate = (timeRange == ReportTimeRange.week)
      ? endDate.subtract(const Duration(days: 6))
      : endDate.subtract(const Duration(days: 29));
      
  return ref.watch(adminReportServiceProvider).getAppointmentsOverTime(startDate, endDate);
});

final appointmentStatusReportProvider = FutureProvider.autoDispose<List<AppointmentStatusReport>>((ref) {
  return ref.watch(adminReportServiceProvider).getAppointmentStatusReport();
});

final stockSummaryReportProvider = FutureProvider.autoDispose<StockSummaryReport>((ref) {
  return ref.watch(adminReportServiceProvider).getStockSummaryReport();
});

// 4. Provider thống kê Kho thuốc theo ngày (cho Line Chart)
final stockOverTimeReportProvider =
    FutureProvider.autoDispose<List<StockReportPoint>>((ref) {
  final timeRange = ref.watch(reportTimeRangeProvider);
  final endDate = DateTime.now();
  final startDate = (timeRange == ReportTimeRange.week)
      ? endDate.subtract(const Duration(days: 6))
      : endDate.subtract(const Duration(days: 29));

  return ref
      .watch(adminReportServiceProvider)
      .getStockReportOverTime(startDate, endDate);
});
