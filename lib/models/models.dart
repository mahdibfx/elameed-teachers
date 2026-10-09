import 'package:teachers_app/models/json.dart';

/// "15:30:00" → "15:30"
String _hhmm(String t) => t.length >= 5 ? t.substring(0, 5) : t;

class AuthUser {
  const AuthUser({required this.name, required this.email, required this.role});

  final String name;
  final String email;
  final String role; // normalized: lowercase, spaces → underscores

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        name: pickString(json, ['name']).trim(),
        email: pickString(json, ['email']),
        role: pickString(json, ['Role', 'role']).toLowerCase().replaceAll(' ', '_'),
      );

  String get initials => name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
}

class LoginResult {
  const LoginResult(this.token, this.user);
  final String token;
  final AuthUser user;

  /// `data: { token, data: {...user} }`
  factory LoginResult.fromJson(Object? data) {
    final map = asMap(data);
    return LoginResult(pickString(map, ['token']), AuthUser.fromJson(asMap(map['data'])));
  }
}

class ScheduleSlot {
  const ScheduleSlot({required this.day, required this.start, required this.end});

  final String day; // "Monday" … "Sunday"
  final String start; // "HH:MM"
  final String end;

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) => ScheduleSlot(
        day: pickString(json, ['day']),
        start: _hhmm(pickString(json, ['start_time'])),
        end: _hhmm(pickString(json, ['end_time'])),
      );
}

class GroupStudent {
  const GroupStudent({
    required this.id,
    required this.name,
    required this.phone,
    this.birthDate,
    this.attended = 0,
    this.marked = 0,
  });

  final int id;
  final String name;
  final String phone;
  final DateTime? birthDate;

  /// Sessions of the group this student was marked present in / marked at all
  /// (`not_held` sessions excluded by the API).
  final int attended;
  final int marked;

  String get attendance => '$attended/$marked';

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    final had = now.month > birthDate!.month || (now.month == birthDate!.month && now.day >= birthDate!.day);
    return now.year - birthDate!.year - (had ? 0 : 1);
  }

  factory GroupStudent.fromJson(Map<String, dynamic> json) => GroupStudent(
        id: pickInt(json, ['student_id', 'id']),
        name: '${pickString(json, ['first_name'])} ${pickString(json, ['last_name'])}'.trim(),
        phone: primaryPhone(json),
        birthDate: DateTime.tryParse(pickString(json, ['birth_date'])),
        attended: pickInt(json, ['attended']),
        marked: pickInt(json, ['marked']),
      );
}

/// Primary number first, else the first one; falls back to the legacy single field.
String primaryPhone(Map<String, dynamic> json) {
  final numbers = asMapList(json['phone_numbers']);
  if (numbers.isEmpty) return pickString(json, ['phone_number']);
  final primary = numbers.firstWhere((n) => n['is_primary'] == true, orElse: () => numbers.first);
  return pickString(primary, ['number']);
}

/// `GET /students?teacher_id=me` — a student with their groups and attendance rate.
class StudentSummary {
  const StudentSummary({required this.student, required this.groups, required this.percentage});

  final GroupStudent student;
  final List<StudentGroupRef> groups;

  /// null when nothing is marked yet.
  final int? percentage;

  factory StudentSummary.fromJson(Map<String, dynamic> json) => StudentSummary(
        student: GroupStudent.fromJson(json),
        groups: asMapList(json['groups']).map(StudentGroupRef.fromJson).toList(),
        percentage: json['attendance_percentage'] is num ? (json['attendance_percentage'] as num).round() : null,
      );
}

class StudentGroupRef {
  const StudentGroupRef({
    required this.id,
    required this.name,
    required this.state,
    required this.courseName,
    this.runningSince,
    this.stoppedAt,
  });

  final int id;
  final String name;
  final String state;
  final String courseName;
  final DateTime? runningSince;
  final DateTime? stoppedAt;

  factory StudentGroupRef.fromJson(Map<String, dynamic> json) => StudentGroupRef(
        id: pickInt(json, ['id']),
        name: pickString(json, ['name']).replaceAll(RegExp(r'\s+'), ' ').trim(),
        state: pickString(json, ['state']),
        courseName: pickString(json, ['course_name']),
        runningSince: DateTime.tryParse(pickString(json, ['running_since'])),
        stoppedAt: DateTime.tryParse(pickString(json, ['stopped_at'])),
      );
}

/// `GET /students/:id/attendance` — one marked session of this student.
class AttendanceEntry {
  const AttendanceEntry({required this.session, required this.present, required this.feedback});

  final Session session;
  final bool present;
  final Evaluation? feedback;

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    final feedback = json['feedback'];
    return AttendanceEntry(
      // Enough of a Session for the history card and the read-only evaluation header.
      session: Session.fromJson({
        'id': json['session_id'],
        'id_group': json['group_id'],
        'group_name': json['group_name'],
        'date': json['date'],
        'time_start': json['time_start'],
        'time_end': json['time_end'],
        'status': json['session_status'],
        'unit': json['unit'],
        'notes': json['notes'],
      }),
      present: pickString(json, ['state']) == 'present',
      feedback: feedback is Map ? Evaluation.fromJson(feedback.cast<String, dynamic>()) : null,
    );
  }
}

/// A teacher's group: `GET /groups/schedules` entry merged with `GET /groups/:id`.
class Group {
  const Group({
    required this.id,
    required this.name,
    required this.state,
    required this.courseName,
    required this.teacherName,
    required this.cycles,
    required this.schedule,
    required this.students,
    required this.heldSessions,
    required this.plannedSessions,
    required this.salaryType,
    required this.salaryAmount,
    this.runningSince,
    this.stoppedAt,
  });

  final int id;
  final String name;
  final String state; // "running", "stopped", …
  final String courseName;
  final String teacherName;
  final int cycles; // number_cycle_payments
  final List<ScheduleSlot> schedule;
  final List<GroupStudent> students;
  final int heldSessions; // current payment cycle
  final int plannedSessions;
  final String salaryType; // teacher_salary_type, e.g. "static"
  final double salaryAmount; // teacher_salary_calculated
  final DateTime? runningSince;

  /// Set while the group is stopped; null for a running one.
  final DateTime? stoppedAt;

  bool get isRunning => state == 'running';
  int get sessionsPerWeek => schedule.length;

  factory Group.fromJson(Map<String, dynamic> schedule, Map<String, dynamic> detail) => Group(
        id: pickInt(schedule, ['group_id']),
        name: pickString(schedule, ['group_name']).replaceAll(RegExp(r'\s+'), ' ').trim(),
        state: pickString(schedule, ['state'], fallback: pickString(detail, ['state'])).toLowerCase(),
        courseName: pickString(schedule, ['course_name']),
        teacherName: pickString(schedule, ['teacher_name']).replaceAll(RegExp(r'\s+'), ' ').trim(),
        cycles: pickInt(schedule, ['number_cycle_payments'], fallback: 1),
        schedule: asMapList(schedule['schedule']).map(ScheduleSlot.fromJson).toList(),
        students: asMapList(detail['students']).map(GroupStudent.fromJson).toList(),
        heldSessions: pickInt(detail, ['cycle_held_sessions']),
        plannedSessions: pickInt(detail, ['cycle_planned_sessions', 'number_of_sessions']),
        salaryType: pickString(detail, ['teacher_salary_type']),
        salaryAmount: pickDouble(detail, ['teacher_salary_calculated', 'teacher_salary_amount']),
        runningSince: DateTime.tryParse(pickString(detail, ['running_since', 'running_since'])) ??
            DateTime.tryParse(pickString(schedule, ['running_since'])),
        stoppedAt: DateTime.tryParse(pickString(detail, ['stopped_at'])) ??
            DateTime.tryParse(pickString(schedule, ['stopped_at'])),
      );
}

enum SessionStatus { pending, held, notHeld }

class Attendee {
  const Attendee({
    required this.studentId,
    required this.name,
    required this.present,
    required this.notes,
    required this.feedback,
    required this.canMark,
  });

  final int studentId;
  final String name;

  /// null = not marked yet.
  final bool? present;
  final String? notes;
  final Evaluation? feedback;
  final bool canMark; // false once the student left the group

  factory Attendee.fromJson(Map<String, dynamic> json) {
    final state = pickStringOrNull(json, ['state']);
    final feedback = json['feedback'];
    return Attendee(
      studentId: pickInt(json, ['id_student']),
      name: pickString(json, ['student_name']).trim(),
      present: state == null ? null : state == 'present',
      notes: pickStringOrNull(json, ['notes']),
      feedback: feedback is Map ? Evaluation.fromJson(feedback.cast<String, dynamic>()) : null,
      canMark: json['can_mark'] != false,
    );
  }
}

/// `GET /sessions` entry; [attendees] is only filled by `GET /sessions/:id`.
class Session {
  const Session({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.courseName,
    required this.teacherName,
    required this.date,
    required this.start,
    required this.end,
    required this.notes,
    required this.unit,
    required this.status,
    required this.groupState,
    required this.cycle,
    required this.studentsCount,
    required this.attendanceCount,
    required this.presentCount,
    required this.absentCount,
    required this.attendanceComplete,
    this.attendees = const [],
    this.room,
    this.bookUnit,
    this.teacherConfirmed = false,
  });

  final int id;
  final int groupId;
  final String groupName;
  final String courseName;
  final String teacherName;
  final DateTime date;
  final String start;
  final String end;
  final String notes;
  final String unit;
  final String status; // raw: pending / held / not_held / ""
  final String groupState; // running / stopped / waiting to complete
  final int cycle; // number_cycle_payment
  final int studentsCount;
  final int attendanceCount;
  final int presentCount;
  final int absentCount;
  final bool attendanceComplete;
  final List<Attendee> attendees;
  final Room? room;
  final BookUnit? bookUnit;

  /// Locked for the teacher once true: no cancelling, only an admin can undo it.
  final bool teacherConfirmed;

  // ponytail: device clock taken as Africa/Algiers (the server's zone); every teacher is in Algeria.
  DateTime _at(String hhmm) {
    final p = hhmm.split(':');
    return DateTime(date.year, date.month, date.day, int.tryParse(p.first) ?? 0, p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
  }

  DateTime get startsAt => _at(start);
  DateTime get endsAt => _at(end);
  bool get hasStarted => !DateTime.now().isBefore(startsAt);
  bool get hasEnded => !DateTime.now().isBefore(endsAt);

  /// Still to come or running now, and not closed by the office.
  bool get isUpcoming => state == SessionStatus.pending && !hasEnded && !inStoppedGroup;

  /// Server rule: own pending session, not confirmed, less than 15 minutes after its start.
  bool get canCancel =>
      isEditable && !teacherConfirmed && DateTime.now().isBefore(startsAt.add(cancelGrace));

  static const cancelGrace = Duration(minutes: 15);

  /// A held session is read-only; the teacher can ask the office to reopen it.
  bool get canAskToEdit => isHeld && groupState == 'running';

  /// The API's own three states; `null`/unknown counts as pending (not decided yet).
  SessionStatus get state => switch (status) {
        'held' => SessionStatus.held,
        'not_held' => SessionStatus.notHeld,
        _ => SessionStatus.pending,
      };

  bool get isHeld => status == 'held';

  /// Teachers may edit unit/notes and attendance only while staff haven't closed the
  /// session — and never in a stopped group, which the API serves read-only.
  bool get isEditable => (status.isEmpty || status == 'pending') && groupState != 'stopped';

  bool get inStoppedGroup => groupState == 'stopped';

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: pickInt(json, ['id']),
        groupId: pickInt(json, ['id_group']),
        groupName: pickString(json, ['group_name']).replaceAll(RegExp(r'\s+'), ' ').trim(),
        courseName: pickString(json, ['course_name']),
        teacherName: pickString(json, ['teacher_name']).replaceAll(RegExp(r'\s+'), ' ').trim(),
        date: DateTime.tryParse(pickString(json, ['date'])) ?? DateTime(1970),
        start: _hhmm(pickString(json, ['time_start'])),
        end: _hhmm(pickString(json, ['time_end'])),
        notes: pickString(json, ['notes']),
        unit: pickString(json, ['unit']),
        status: pickString(json, ['status']),
        groupState: pickString(json, ['group_state']),
        cycle: pickInt(json, ['number_cycle_payment'], fallback: 1),
        studentsCount: pickInt(json, ['students_count']),
        attendanceCount: pickInt(json, ['attendance_count']),
        presentCount: pickInt(json, ['present_count']),
        absentCount: pickInt(json, ['absent_count']),
        attendanceComplete: json['attendance_complete'] == true,
        attendees: asMapList(json['attendance']).map(Attendee.fromJson).toList(),
        room: json['room'] is Map ? Room.fromJson(asMap(json['room'])) : null,
        bookUnit: json['book_unit'] is Map ? BookUnit.fromJson(asMap(json['book_unit'])) : null,
        teacherConfirmed: json['teacher_confirmed'] == true,
      );
}

class Room {
  const Room({required this.id, required this.index, required this.floor});

  final int id;
  final String index; // room_index, e.g. "B2"
  final int floor;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: pickInt(json, ['id']),
        index: pickString(json, ['room_index']),
        floor: pickInt(json, ['floor_number']),
      );
}

/// A unit of a language book, as attached to a session.
class BookUnit {
  const BookUnit({required this.id, required this.name, this.bookName = ''});

  final int id;
  final String name;
  final String bookName;

  String get label => bookName.isEmpty ? name : '$bookName · $name';

  factory BookUnit.fromJson(Map<String, dynamic> json) => BookUnit(
        id: pickInt(json, ['id']),
        name: pickString(json, ['name']),
        bookName: pickString(json, ['book_name']),
      );
}

/// `GET /language-books` entry with its units.
class Book {
  const Book({required this.id, required this.name, required this.units});

  final int id;
  final String name;
  final List<BookUnit> units;

  factory Book.fromJson(Map<String, dynamic> json) {
    final name = pickString(json, ['name']);
    return Book(
      id: pickInt(json, ['id']),
      name: name,
      units: asMapList(json['units']).map((u) => BookUnit.fromJson({...u, 'book_name': name})).toList(),
    );
  }
}

/// `GET /session-cancel-reasons` entry.
/// `GET /teacher/directory` — a colleague who can be suggested as a replacement.
class TeacherRef {
  const TeacherRef({required this.id, required this.name});

  final int id;
  final String name;

  factory TeacherRef.fromJson(Map<String, dynamic> json) => TeacherRef(
        id: pickInt(json, ['id']),
        name: '${pickString(json, ['first_name'])} ${pickString(json, ['last_name'])}'.replaceAll(RegExp(r'\s+'), ' ').trim(),
      );
}

/// `POST /sessions/:id/edit-requests` — asking the office to reopen a held session.
class EditRequest {
  const EditRequest({required this.id, required this.status, required this.reason, required this.decisionNote, required this.createdAt});

  final int id;
  final String status; // pending / approved / rejected / withdrawn
  final String reason;
  final String decisionNote;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';

  factory EditRequest.fromJson(Map<String, dynamic> json) => EditRequest(
        id: pickInt(json, ['id']),
        status: pickString(json, ['status']),
        reason: pickString(json, ['reason']),
        decisionNote: pickString(json, ['decision_note']),
        createdAt: DateTime.tryParse(pickString(json, ['created_at'])),
      );
}

/// `GET /teacher-payments` — one payout recorded by the office.
class TeacherPayment {
  const TeacherPayment({
    required this.id,
    required this.amount,
    required this.paidAt,
    required this.groupName,
    required this.periodFrom,
    required this.periodTo,
    required this.note,
  });

  final int id;
  final double amount;
  final DateTime? paidAt;
  final String groupName;
  final DateTime? periodFrom;
  final DateTime? periodTo;
  final String note;

  factory TeacherPayment.fromJson(Map<String, dynamic> json) => TeacherPayment(
        id: pickInt(json, ['id']),
        amount: pickDouble(json, ['amount']),
        paidAt: DateTime.tryParse(pickString(json, ['paid_at'])),
        groupName: pickString(asMap(json['group']), ['name']).replaceAll(RegExp(r'\s+'), ' ').trim(),
        periodFrom: DateTime.tryParse(pickString(json, ['period_from'])),
        periodTo: DateTime.tryParse(pickString(json, ['period_to'])),
        note: pickString(json, ['note']),
      );
}

/// `GET /teacher-payments/summary` — the Payments tab header.
class PaymentSummary {
  const PaymentSummary({
    required this.paymentsCount,
    required this.totalPaid,
    required this.paidThisYear,
    required this.lastPayment,
    required this.groups,
  });

  final int paymentsCount;
  final double totalPaid;
  final double paidThisYear;
  final TeacherPayment? lastPayment;
  final List<PaymentGroup> groups;

  factory PaymentSummary.fromJson(Map<String, dynamic> json) => PaymentSummary(
        paymentsCount: pickInt(json, ['payments_count']),
        totalPaid: pickDouble(json, ['total_paid']),
        paidThisYear: pickDouble(json, ['paid_this_year']),
        lastPayment: json['last_payment'] is Map ? TeacherPayment.fromJson(asMap(json['last_payment'])) : null,
        groups: asMapList(json['groups']).map(PaymentGroup.fromJson).toList(),
      );
}

/// One of the teacher's groups with its salary terms and what was paid for it.
class PaymentGroup {
  const PaymentGroup({
    required this.id,
    required this.name,
    required this.state,
    required this.salaryType,
    required this.salaryAmount,
    required this.paidForGroup,
  });

  final int id;
  final String name;
  final String state;
  final String salaryType; // static / percentage, may be empty
  final double? salaryAmount;
  final double paidForGroup;

  factory PaymentGroup.fromJson(Map<String, dynamic> json) => PaymentGroup(
        id: pickInt(json, ['id']),
        name: pickString(json, ['name']).replaceAll(RegExp(r'\s+'), ' ').trim(),
        state: pickString(json, ['state']),
        salaryType: pickString(json, ['salary_type']),
        salaryAmount: json['salary_amount'] == null ? null : pickDouble(json, ['salary_amount']),
        paidForGroup: pickDouble(json, ['paid_for_group']),
      );
}

class CancelReason {
  const CancelReason({required this.id, required this.name});

  final int id;
  final String name;

  factory CancelReason.fromJson(Map<String, dynamic> json) =>
      CancelReason(id: pickInt(json, ['id']), name: pickString(json, ['name']));
}

/// The API's `AttendanceFeedback`. Unknown keys are kept in [_extra] and sent back as-is.
class Evaluation {
  Evaluation({
    this.onTime = true,
    this.arrivalTime,
    this.leftEarly = false,
    this.leavingTime = '',
    this.understanding = 3,
    this.concentration = 3,
    this.engagement = 3,
    this.homework = 'no_homework',
    this.nextStep,
    this.behavior = 0,
    this.note = '',
    Map<String, dynamic>? extra,
  }) : _extra = extra ?? {};

  bool onTime;
  String? arrivalTime;
  bool leftEarly;
  String leavingTime;
  int understanding; // 1 very weak … 5 excellent
  int concentration; // 1..5
  int engagement; // 1..5
  String homework; // done / partial / not_done / no_homework
  String? nextStep; // review / practice / participate_more / improve_concentration / nothing_specific
  int behavior; // 0 no issue … 3 serious
  String note;
  final Map<String, dynamic> _extra;

  static const _known = {'arrival', 'departure', 'understanding', 'concentration', 'engagement', 'homework', 'next_step', 'behavior', 'note'};

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    final arrival = asMap(json['arrival']);
    final departure = asMap(json['departure']);
    return Evaluation(
      onTime: arrival['status'] != 'late',
      arrivalTime: pickStringOrNull(arrival, ['time']),
      leftEarly: departure['status'] == 'left_early',
      leavingTime: pickString(departure, ['time']),
      understanding: pickInt(json, ['understanding'], fallback: 3).clamp(1, 5),
      concentration: pickInt(json, ['concentration'], fallback: 3).clamp(1, 5),
      engagement: pickInt(json, ['engagement'], fallback: 3).clamp(1, 5),
      homework: pickString(json, ['homework'], fallback: 'no_homework'),
      nextStep: pickStringOrNull(json, ['next_step']),
      behavior: pickInt(json, ['behavior']).clamp(0, 3),
      note: pickString(json, ['note']),
      extra: {for (final e in json.entries) if (!_known.contains(e.key)) e.key: e.value},
    );
  }

  Map<String, dynamic> toJson() => {
        ..._extra,
        'arrival': {'time': arrivalTime, 'status': onTime ? 'on_time' : 'late'},
        'departure': {'time': leftEarly && leavingTime.isNotEmpty ? leavingTime : null, 'status': leftEarly ? 'left_early' : 'normal'},
        'understanding': understanding,
        'concentration': concentration,
        'engagement': engagement,
        'homework': homework,
        'next_step': nextStep,
        'behavior': behavior,
        'note': note.isEmpty ? null : note,
      };

  Evaluation copy() => Evaluation.fromJson(toJson());
}

/// One row of `POST /sessions/:id/attendance/bulk`. Null fields are omitted = "keep stored value".
class AttendanceWrite {
  const AttendanceWrite({required this.studentId, this.present, this.feedback});

  final int studentId;
  final bool? present;
  final Evaluation? feedback;

  Map<String, dynamic> toJson() => {
        'id_student': studentId,
        if (present != null) 'state': present! ? 'present' : 'absent',
        if (feedback != null) 'feedback': feedback!.toJson(),
      };
}
