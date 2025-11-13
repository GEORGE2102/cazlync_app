import 'package:intl/intl.dart';

class Formatters {
  static String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      symbol: 'K',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  static String formatMileage(int mileage) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(mileage)} km';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
}
