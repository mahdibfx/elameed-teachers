import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:teachers_app/models/models.dart';

// Fixtures are real El Ameed responses (2026-09-22) with student names/phones anonymised.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('Group merges schedule entry + detail', () {
    final g = Group.fromJson(fixture('group_schedule'), fixture('group_detail'));
    expect(g.id, 48);
    expect(g.isRunning, isTrue);
    expect(g.courseName, 'Kids English Course');
    expect(g.sessionsPerWeek, g.schedule.length);
    expect(g.students, hasLength(2));
    expect(g.heldSessions, 8);
    expect(g.plannedSessions, 26);
    expect(g.salaryAmount, 800);
    expect(g.runningSince, isNotNull);
  });

  test('ScheduleSlot trims seconds', () {
    final slot = ScheduleSlot.fromJson({'day': 'Tuesday', 'start_time': '15:30:00', 'end_time': '17:00'});
    expect((slot.day, slot.start, slot.end), ('Tuesday', '15:30', '17:00'));
  });

  test('Session detail parses attendees and feedback', () {
    final s = Session.fromJson(fixture('session_detail'));
    expect(s.id, 417);
    expect(s.start, '09:30'); // "09:30:00" trimmed
    expect(s.state, SessionStatus.held);
    expect(s.attendees.first.present, isTrue);
    expect(s.attendees.first.feedback, isNull);
    final e = s.attendees[1].feedback!;
    expect(s.attendees[1].present, isFalse);
    expect((e.onTime, e.leftEarly, e.leavingTime), (false, true, '15:30'));
    expect((e.understanding, e.homework, e.nextStep, e.behavior), (2, 'partial', 'practice', 1));
  });

  test('Evaluation round-trips and keeps unknown keys', () {
    final raw = fixture('session_detail')['attendance'][1]['feedback'] as Map<String, dynamic>;
    final json = Evaluation.fromJson(raw).toJson();
    expect(json['custom_key'], 7);
    expect(json['departure'], {'time': '15:30', 'status': 'left_early'});
    expect(json['arrival'], {'time': null, 'status': 'late'});
    expect(json['next_step'], 'practice');
  });

  test('AttendanceWrite omits untouched fields', () {
    expect(const AttendanceWrite(studentId: 3).toJson(), {'id_student': 3});
    expect(const AttendanceWrite(studentId: 3, present: false).toJson(), {'id_student': 3, 'state': 'absent'});
  });

  test('state mirrors the API status', () {
    Session s(String status) => Session.fromJson({'status': status});
    expect(s('pending').state, SessionStatus.pending);
    expect(s('held').state, SessionStatus.held);
    expect(s('not_held').state, SessionStatus.notHeld);
    expect(s('').state, SessionStatus.pending); // not decided yet
  });

  test('Roster student carries birth date and attendance counts', () {
    final list = (fixture('group_roster')['data'] as List).map((e) => GroupStudent.fromJson(e as Map<String, dynamic>)).toList();
    final s = list.first;
    expect(s.name, 'Student 0');
    expect(s.phone, '0550000000'); // primary number wins
    expect(s.attendance, '${s.attended}/${s.marked}');
    expect(s.birthDate, isNotNull);
    expect(s.age, greaterThan(0));
  });

  test('StudentSummary parses groups and percentage', () {
    final s = StudentSummary.fromJson(fixture('student_summary'));
    expect(s.student.name, 'Student 0');
    expect(s.student.age, DateTime.now().year - 2010 - (DateTime.now().month < 5 ? 1 : 0));
    expect(s.groups.first.state, 'running');
    expect(s.percentage, isA<int>());
    expect(StudentSummary.fromJson({'attendance_percentage': null}).percentage, isNull);
  });

  test('AttendanceEntry builds a session for the history card', () {
    final e = AttendanceEntry.fromJson(fixture('attendance_entry'));
    expect(e.present, isTrue);
    expect(e.session.id, greaterThan(0));
    expect(e.session.groupName, isNotEmpty);
    expect(e.session.start, hasLength(5));
    expect(e.feedback?.understanding, 4);
    expect(e.feedback?.homework, 'done');
  });

  test('Session is editable only while pending', () {
    Session s(String status) => Session.fromJson({'status': status});
    expect(s('pending').isEditable, isTrue);
    expect(s('').isEditable, isTrue);
    expect(s('held').isEditable, isFalse);
    expect(s('not_held').isEditable, isFalse);
  });

  test('AuthUser normalizes role', () {
    expect(AuthUser.fromJson({'name': 'Sara Benali', 'Role': 'Team Onsite'}).role, 'team_onsite');
    expect(AuthUser.fromJson({'name': 'Sara Benali'}).initials, 'SB');
  });
}
