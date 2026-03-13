// lib/utils/formatters.dart
import 'package:intl/intl.dart';

class AppFormatters {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm - dd/MM/yyyy').format(dateTime);
  }
}