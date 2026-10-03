import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _nairaFormatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  static final NumberFormat _nairaDecimalsFormatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  );

  /// Format as Nigerian Naira without decimals: e.g. ₦12,500
  static String format(num amount) {
    return _nairaFormatter.format(amount);
  }

  /// Format with decimal places if needed: e.g. ₦12,500.50
  static String formatWithDecimals(num amount) {
    return _nairaDecimalsFormatter.format(amount);
  }
}
