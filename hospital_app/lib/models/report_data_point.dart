// lib/models/report_data_point.dart

class ReportDataPoint {
  final DateTime date;
  final int count;

  ReportDataPoint({
    required this.date,
    required this.count,
  });
}

class AppointmentStatusReport {
  final String statusDisplay;
  final int count;

  AppointmentStatusReport({
    required this.statusDisplay,
    required this.count,
  });
}

// 3. Model cho báo cáo thống kê kho (biểu đồ cột)
class StockSummaryReport {
  final int stockIn;
  final int stockOutManual;
  final int stockOutPrescription;

  StockSummaryReport({
    required this.stockIn,
    required this.stockOutManual,
    required this.stockOutPrescription,
  });
}

class StockReportPoint {
  final DateTime date;
  final int stockIn;
  final int stockOutManual;
  final int stockOutPrescription;
  

  StockReportPoint({
    required this.date,
    required this.stockIn,
    required this.stockOutManual,
    required this.stockOutPrescription,
    
  });

  factory StockReportPoint.fromJson(Map<String, dynamic> json) {
    return StockReportPoint(
      date: DateTime.parse(json['date']),
      stockIn: json['stock_in'] ?? 0,
      stockOutManual: json['stock_out_manual'] ?? 0,
      stockOutPrescription: json['stock_out_prescription'] ?? 0,
      
    );
  }
}