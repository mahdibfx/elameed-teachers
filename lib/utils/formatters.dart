import 'package:intl/intl.dart';

// Numbers stay Latin in every language (Algerian usage); only day names follow the locale.

/// "Saturday 09/19/2026" / "samedi 09/19/2026" / "السبت 09/19/2026"
String fullDate(DateTime d) => '${DateFormat.EEEE().format(d)} ${shortDate(d)}';

/// "09/19/2026"
String shortDate(DateTime d) => DateFormat('MM/dd/yyyy', 'en').format(d);

const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

/// API sends English day names ("Tuesday"); show them in the current language.
String localDay(String apiDay) {
  final i = _days.indexWhere((d) => d.toLowerCase() == apiDay.toLowerCase());
  return i < 0 ? apiDay : DateFormat.EEEE().format(DateTime(2024, 1, 1 + i)); // 2024-01-01 is a Monday
}

/// "20 000"
String amount(int v) => NumberFormat('#,###', 'en').format(v).replaceAll(',', ' ');

/// Days between [d] and [now], calendar-wise (ignores time of day).
int daysAgo(DateTime d, DateTime now) =>
    DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;

/// Translation key + arg for the relative label: tomorrow, today, yesterday, "3d ago", "2w ago".
(String key, int n) relativeDayKey(DateTime d, DateTime now) {
  final days = daysAgo(d, now);
  if (days < -1) return ('date.in_days', -days);
  if (days == -1) return ('date.tomorrow', 1);
  if (days == 0) return ('date.today', 0);
  if (days == 1) return ('date.yesterday', 1);
  if (days < 7) return ('date.days_ago', days);
  return ('date.weeks_ago', days ~/ 7);
}
