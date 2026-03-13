
// lib/services/admin_report_service.dart
import 'package:hospital_app/models/report_data_point.dart'; // <<< IMPORT MODEL TỪ FILE RIÊNG
import 'package:hospital_app/services/dio_client.dart';
import 'package:intl/intl.dart';


class AdminReportService {
  final _dio = DioClient().dio;

  Future<List<ReportDataPoint>> getAppointmentsOverTime(DateTime startDate, DateTime endDate) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    try {
      final response = await _dio.get(
        '/admin/reports/appointments-over-time/',
        queryParameters: {
          'start_date': dateFormat.format(startDate),
          'end_date': dateFormat.format(endDate),
        },
      );
      final data = response.data as List;
      return data.map((json) {
        return ReportDataPoint(
          date: DateTime.parse(json['date']),
          count: json['count'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AppointmentStatusReport>> getAppointmentStatusReport() async {
    try {
      final response = await _dio.get('/admin/reports/appointment-status/');
      final data = response.data as List;
      return data.map((json) => AppointmentStatusReport(
        statusDisplay: json['status_display'],
        count: json['count'],
      )).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<StockSummaryReport> getStockSummaryReport() async {
    try {
      final response = await _dio.get('/admin/reports/stock-summary/');
      final data = response.data as Map<String, dynamic>;
      return StockSummaryReport(
        stockIn: data['stock_in'] ?? 0,
        stockOutManual: data['stock_out_manual'] ?? 0,
        stockOutPrescription: data['stock_out_prescription'] ?? 0,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<StockReportPoint>> getStockReportOverTime(DateTime start, DateTime end) async {
   
  final dateFormat = DateFormat('yyyy-MM-dd');
    
  try {
    final response = await _dio.get(
      '/admin/reports/stock-over-time/',
      queryParameters: {
        'start_date': dateFormat.format(start),
          'end_date': dateFormat.format(end),
      },
    );

    return (response.data as List)
        .map((e) => StockReportPoint.fromJson(e))
        .toList();
  } catch (e) {
    rethrow;
  }
}
}