import 'package:flutter_test/flutter_test.dart';
import 'package:teachers_app/models/models.dart';

/// A 10:00–11:00 session [days] from today.
Session _session(int days, {String status = 'pending', bool confirmed = false}) {
  final d = DateTime.now().add(Duration(days: days));
  return Session.fromJson({
    'id': 1,
    'date': '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
    'time_start': '10:00:00',
    'time_end': '11:00:00',
    'status': status,
    'teacher_confirmed': confirmed,
    'room': {'id': 4, 'room_index': 'B2', 'floor_number': 1},
  });
}

void main() {
  test('tomorrow: upcoming, cancellable unless confirmed or closed', () {
    expect(_session(1).isUpcoming, isTrue);
    expect(_session(1).canCancel, isTrue);
    expect(_session(1, confirmed: true).canCancel, isFalse);
    expect(_session(1, status: 'not_held').canCancel, isFalse);
    expect(_session(1, status: 'not_held').isUpcoming, isFalse);
  });

  test('yesterday: history, not cancellable', () {
    expect(_session(-1).isUpcoming, isFalse);
    expect(_session(-1).canCancel, isFalse);
  });

  test('room and confirmation are parsed', () {
    final s = _session(1, confirmed: true);
    expect(s.room?.index, 'B2');
    expect(s.teacherConfirmed, isTrue);
  });
}
