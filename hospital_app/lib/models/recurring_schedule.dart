// // lib/models/recurring_schedule.dart
// import 'package:flutter/material.dart';

// class RecurringSchedule {
//   final int id;
//   final int doctorId;
//   final int dayOfWeek; // Backend trả về: 0=Thứ Hai, 1=Thứ Ba, ..., 6=Chủ Nhật
//   final String dayOfWeekDisplay; // Backend trả về: "Thứ Hai", "Thứ Ba"...
//   final String  startTime;
//   final String  endTime;

//   RecurringSchedule({
//     required this.id,
//     required this.doctorId,
//     required this.dayOfWeek,
//     required this.dayOfWeekDisplay,
//     required this.startTime,
//     required this.endTime,
//   });
//   factory RecurringSchedule.fromJson(Map<String, dynamic> j) {
//   // --- doctorId: nhận cả doctor_id (int), doctor_info.id (object), hoặc doctor (int)
//   int doctorId;
//   if (j.containsKey('doctor_id')) {
//     doctorId = (j['doctor_id'] as num).toInt();
//   } else if (j['doctor_info'] is Map<String, dynamic>) {
//     final m = j['doctor_info'] as Map<String, dynamic>;
//     doctorId = (m['id'] as num).toInt();
//   } else if (j['doctor'] is num) {
//     doctorId = (j['doctor'] as num).toInt();
//   } else {
//     throw const FormatException('Missing doctor id');
//   }

//   // --- day_of_week: ép về int an toàn
//   final Object? dowRaw = j.containsKey('day_of_week') ? j['day_of_week'] : j['dayOfWeek'];
//   final int dayOfWeek = dowRaw is num ? dowRaw.toInt() : int.tryParse('${dowRaw ?? 0}') ?? 0;

//   // --- start_time / end_time: luôn chuyển sang String, tránh lỗi cast
//   final String startTime = (j['start_time'] ?? j['startTime'])?.toString() ?? '';
//   final String endTime   = (j['end_time']   ?? j['endTime'])?.toString()   ?? '';

//   return RecurringSchedule(
//     id: (j['id'] as num).toInt(),
//     doctorId: doctorId,
//     dayOfWeek: dayOfWeek,
//     startTime: startTime,
//     endTime: endTime,
//   );
// }

// }

class RecurringSchedule {
  final int id;
  final int doctorId;
  final int dayOfWeek;            // 0..6
  final String dayOfWeekDisplay;  // "Thứ Hai", "Thứ Ba", ...
  final String startTime;         // "08:00:00"
  final String endTime;           // "11:30:00"

  const RecurringSchedule({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.dayOfWeekDisplay,
    required this.startTime,
    required this.endTime,
  });

  /// Map từ JSON (chịu được nhiều biến thể khoá)
  factory RecurringSchedule.fromJson(Map<String, dynamic> j) {
    // --- doctorId: chấp nhận doctor_id (int), doctor_info.id (object), hoặc doctor (int)
    late final int doctorId;
    if (j.containsKey('doctor_id')) {
      doctorId = (j['doctor_id'] as num).toInt();
    } else if (j['doctor_info'] is Map<String, dynamic>) {
      doctorId = ((j['doctor_info'] as Map<String, dynamic>)['id'] as num).toInt();
    } else if (j['doctor'] is num) {
      doctorId = (j['doctor'] as num).toInt();
    } else {
      throw const FormatException('Missing doctor id');
    }

    // --- day_of_week
    final Object? dowRaw = j.containsKey('day_of_week') ? j['day_of_week'] : j['dayOfWeek'];
    final int dayOfWeek =
        (dowRaw is num) ? dowRaw.toInt() : int.tryParse('${dowRaw ?? 0}') ?? 0;

    // --- day_of_week_display (nếu backend không gửi thì tự suy ra)
    final String dayOfWeekDisplay =
        (j['day_of_week_display'] ?? j['dayOfWeekDisplay'])?.toString()
            ?? _dowNameVi(dayOfWeek);

    // --- times (luôn về String an toàn)
    final String startTime = (j['start_time'] ?? j['startTime'])?.toString() ?? '';
    final String endTime   = (j['end_time']   ?? j['endTime'])?.toString()   ?? '';

    return RecurringSchedule(
      id: (j['id'] as num).toInt(),
      doctorId: doctorId,
      dayOfWeek: dayOfWeek,
      dayOfWeekDisplay: dayOfWeekDisplay,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctor_id': doctorId,
        'day_of_week': dayOfWeek,
        'day_of_week_display': dayOfWeekDisplay,
        'start_time': startTime,
        'end_time': endTime,
      };

  static String _dowNameVi(int d) {
    const names = [
      'Chủ nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư',
      'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'
    ];
    return (d >= 0 && d < names.length) ? names[d] : '';
  }
}
