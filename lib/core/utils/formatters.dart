import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Fmt {
  static final NumberFormat _n = NumberFormat.decimalPattern();

  static String number(num v) => _n.format(v.round());

  static String _trim(double v) =>
      v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

  /// Pakistani money style: 88.2 Lac, 1.4 Cr.
  static String pkr(num v) {
    if (v >= 1e7) return 'PKR ${_trim(v / 1e7)} Cr';
    if (v >= 1e5) return 'PKR ${_trim(v / 1e5)} Lac';
    return 'PKR ${number(v)}';
  }

  static String sqft(num v) => '${number(v)} sqft';
  static String marla(num sqft) => (sqft / AppConstants.sqftPerMarla).toStringAsFixed(1);

  static String title(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');

  /// "2026-11-18T10:20:00" -> "18 Nov, 10:20"
  static String when(String iso) {
    final d = DateTime.tryParse(iso);
    return d == null ? iso : DateFormat('d MMM, HH:mm').format(d.toLocal());
  }
}

class Validators {
  static String? required(String? v, [String label = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? number(String? v, double min, double max, String label, String unit) {
    final n = double.tryParse((v ?? '').replaceAll(',', '').trim());
    if (n == null) return 'Enter a number for $label';
    if (n < min || n > max) {
      return '$label must be between ${Fmt.number(min)} and ${Fmt.number(max)} $unit';
    }
    return null;
  }

  static String? email(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Email is required';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
        ? null
        : 'Enter a valid email, e.g. name@example.com';
  }

  static String? password(String? v) =>
      (v == null || v.length < 6) ? 'Use at least 6 characters' : null;
}