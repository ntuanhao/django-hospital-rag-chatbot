// lib/services/admin_monitoring_service.dart

import 'package:hospital_app/models/appointment.dart';
import 'package:hospital_app/providers/admin_monitoring_provider.dart'; // Sẽ sửa import này ở bước sau
import 'package:hospital_app/services/dio_client.dart';
import 'package:intl/intl.dart';

// Service để gọi API
class AdminMonitoringService {
  final _dio = DioClient().dio;

  Future<List<Appointment>> getFilteredAppointments(AppointmentFilter filter) async {
    final query = <String, dynamic>{};
    final dateFormat = DateFormat('yyyy-MM-dd');

    if (filter.startDate != null) query['start_date'] = dateFormat.format(filter.startDate!);
    if (filter.endDate != null) query['end_date'] = dateFormat.format(filter.endDate!);
    if (filter.doctorId != null) query['doctor'] = filter.doctorId;
    if (filter.status != null) query['status'] = filter.status;
    
    try {
      final response = await _dio.get('/appointments/', queryParameters: query);
      final data = response.data as List;
      return data.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}