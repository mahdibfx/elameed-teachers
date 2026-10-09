import 'package:flutter_test/flutter_test.dart';
import 'package:teachers_app/utils/formatters.dart';

void main() {
  test('relativeDayKey', () {
    final now = DateTime(2026, 9, 19, 23, 30);
    expect(relativeDayKey(DateTime(2026, 9, 19, 8), now), ('date.today', 0));
    expect(relativeDayKey(DateTime(2026, 9, 18, 23, 59), now), ('date.yesterday', 1));
    expect(relativeDayKey(DateTime(2026, 9, 14), now), ('date.days_ago', 5));
    expect(relativeDayKey(DateTime(2026, 9, 4), now), ('date.weeks_ago', 2));
    expect(relativeDayKey(DateTime(2026, 9, 20, 8), now), ('date.tomorrow', 1));
    expect(relativeDayKey(DateTime(2026, 9, 22), now), ('date.in_days', 3));
  });

  test('amount', () => expect(amount(20000), '20 000'));
}
