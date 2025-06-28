import 'package:intl/intl.dart';

class FormatUtils {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  static String formatDate(String date) {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
  }
}