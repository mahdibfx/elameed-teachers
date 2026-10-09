import 'package:fpdart/fpdart.dart' hide Group;
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/extensions/api_response_extension.dart';
import 'package:teachers_app/models/failure.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/api/api_teacher_service.dart';

class TeacherService {
  final _api = locator<ApiTeacherService>();

  List<Group>? _groups;
  final _sessionDetails = <int, Session>{};

  void clearCache() {
    _groups = null;
    _sessionDetails.clear();
  }

  /// Schedules + one `GET /groups/:id` per group (roster, progress, salary). Cached until [refresh].
  Future<Either<Failure, List<Group>>> getGroups({bool refresh = false}) async {
    if (_groups != null && !refresh) return Either.right(_groups!);
    final schedules = await _api.fetchGroupSchedules().toEither();
    return schedules.fold((f) async => Either.left(f), (entries) async {
      final details = await Future.wait(entries.map((e) => _api.fetchGroupDetail(e['group_id'] as int? ?? 0).toEither()));
      final groups = <Group>[];
      for (var i = 0; i < entries.length; i++) {
        // A group whose detail fails still shows, just without roster/progress.
        groups.add(Group.fromJson(entries[i], details[i].getOrElse((_) => const {})));
      }
      return Either.right(_groups = groups);
    });
  }

  Future<Either<Failure, List<Group>>> groupsOf(int studentId) async =>
      (await getGroups()).map((gs) => gs.where((g) => g.students.any((s) => s.id == studentId)).toList());

  /// Newest first.
  Future<Either<Failure, List<Session>>> getSessions({int? groupId}) async =>
      (await _api.fetchSessions(groupId: groupId).toEither()).map((s) => s..sort(_newestFirst));

  Future<Either<Failure, Session>> getSession(int id) async {
    final result = await _api.fetchSession(id).toEither();
    result.map((s) => _sessionDetails[id] = s);
    return result;
  }

  /// Roster of one group with each student's attended/marked counts.
  Future<Either<Failure, List<GroupStudent>>> getGroupStudents(int groupId) =>
      _api.fetchGroupStudents(groupId).toEither();

  /// Every student of the teacher's groups, with their attendance rate.
  Future<Either<Failure, List<StudentSummary>>> getStudents() => _api.fetchStudents().toEither();

  /// One student's marked sessions (optionally inside one group), newest first.
  Future<Either<Failure, List<AttendanceEntry>>> getStudentAttendance(int studentId, {int? groupId}) =>
      _api.fetchStudentAttendance(studentId, groupId: groupId).toEither();

  Future<Either<Failure, Session>> updateSession(int id, Map<String, dynamic> fields) =>
      _api.updateSession(id, fields).toEither();

  Future<Either<Failure, Session>> confirmSession(int id) => _api.confirmSession(id).toEither();

  Future<Either<Failure, Unit>> cancelSession(
    int id, {
    required int reasonId,
    String? description,
    int? replacementTeacherId,
    String? replacementName,
    String? filePath,
  }) async =>
      (await _api
              .cancelSession(
                id,
                reasonId: reasonId,
                description: description,
                replacementTeacherId: replacementTeacherId,
                replacementName: replacementName,
                filePath: filePath,
              )
              .toEither())
          .map((_) => unit);

  Future<Either<Failure, List<TeacherRef>>> getTeacherDirectory({String? search}) =>
      _api.fetchTeacherDirectory(search: search).toEither();

  Future<Either<Failure, EditRequest>> askToEdit(int sessionId, {String? reason}) =>
      _api.createEditRequest(sessionId, reason: reason).toEither();

  Future<Either<Failure, List<EditRequest>>> getEditRequests(int sessionId) =>
      _api.fetchEditRequests(sessionId).toEither();

  Future<Either<Failure, Unit>> withdrawEditRequest(int id) async =>
      (await _api.withdrawEditRequest(id).toEither()).map((_) => unit);

  Future<Either<Failure, PaymentSummary>> getPaymentSummary() => _api.fetchPaymentSummary().toEither();

  Future<Either<Failure, List<TeacherPayment>>> getPayments() => _api.fetchPayments().toEither();

  Future<Either<Failure, Unit>> registerDevice(String token, {String? platform}) async =>
      (await _api.registerDevice(token, platform: platform).toEither()).map((_) => unit);

  Future<Either<Failure, Unit>> unregisterDevice(String token) async =>
      (await _api.unregisterDevice(token).toEither()).map((_) => unit);

  // Reference lists barely change: fetched once per app run.
  List<CancelReason>? _reasons;
  List<Room>? _rooms;
  List<Book>? _books;

  Future<Either<Failure, List<CancelReason>>> getCancelReasons() async =>
      _reasons != null ? Either.right(_reasons!) : (await _api.fetchCancelReasons().toEither()).map((r) => _reasons = r);

  Future<Either<Failure, List<Room>>> getRooms() async =>
      _rooms != null ? Either.right(_rooms!) : (await _api.fetchRooms().toEither()).map((r) => _rooms = r);

  Future<Either<Failure, List<Book>>> getBooks() async =>
      _books != null ? Either.right(_books!) : (await _api.fetchBooks().toEither()).map((b) => _books = b);

  Future<Either<Failure, Unit>> sendReport({String? category, String? description, String? imagePath, int? roomId}) async =>
      (await _api.sendReport(category: category, description: description, imagePath: imagePath, roomId: roomId).toEither())
          .map((_) => unit);

  Future<Either<Failure, Unit>> saveAttendance(int sessionId, List<AttendanceWrite> records) async {
    final result = await _api.saveAttendance(sessionId, records).toEither();
    _sessionDetails.remove(sessionId);
    return result.map((_) => unit);
  }

  static int _newestFirst(Session a, Session b) {
    final byDate = b.date.compareTo(a.date);
    return byDate != 0 ? byDate : b.start.compareTo(a.start);
  }
}
