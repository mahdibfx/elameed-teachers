import 'package:dio/dio.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/models/api_response.dart';
import 'package:teachers_app/models/json.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/api/api_endpoints.dart';
import 'package:teachers_app/services/dio_service.dart';

/// Every call is scoped to the logged-in teacher with `teacher_id=me`.
class ApiTeacherService {
  final _dio = locator<DioService>().dio;

  /// Raw schedule entries; merged with [fetchGroupDetail] into a [Group] by TeacherService.
  /// `state: 'all'` also brings the teacher's stopped groups (read-only).
  Future<ApiResponse<List<Map<String, dynamic>>>> fetchGroupSchedules() async {
    final res = await _dio.get(ApiEndpoints.groupsSchedules, queryParameters: {'teacher_id': 'me', 'state': 'all'});
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, asMapList);
  }

  Future<ApiResponse<Map<String, dynamic>>> fetchGroupDetail(int id) async {
    final res = await _dio.get(ApiEndpoints.group(id));
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, asMap);
  }

  /// Roster with `birth_date` and the attended/marked counts. Paginated envelope: `data.data`.
  Future<ApiResponse<List<GroupStudent>>> fetchGroupStudents(int groupId) async {
    final res = await _dio.get(ApiEndpoints.groupStudents(groupId));
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      res.statusCode!,
      (data) => asMapList(data is Map ? data['data'] : data).map(GroupStudent.fromJson).toList(),
    );
  }

  Future<ApiResponse<List<StudentSummary>>> fetchStudents() async {
    final res = await _dio.get(ApiEndpoints.students, queryParameters: {'teacher_id': 'me', 'group_state': 'all'});
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      res.statusCode!,
      (data) => asMapList(data is Map ? data['data'] : data).map(StudentSummary.fromJson).toList(),
    );
  }

  /// Marked sessions of one student, newest first, with their feedback.
  Future<ApiResponse<List<AttendanceEntry>>> fetchStudentAttendance(int studentId, {int? groupId}) async {
    final res = await _dio.get(
      ApiEndpoints.studentAttendance(studentId),
      queryParameters: {'group_id': ?groupId},
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      res.statusCode!,
      (data) => asMapList(asMap(data)['sessions']).map(AttendanceEntry.fromJson).toList(),
    );
  }

  /// Teacher may edit their own pending session: any of unit, notes, book_unit_id, room_id
  /// (null clears it, a missing key keeps it).
  Future<ApiResponse<Session>> updateSession(int id, Map<String, dynamic> fields) async {
    final res = await _dio.patch(ApiEndpoints.session(id), data: fields);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => Session.fromJson(asMap(d)));
  }

  /// "I will hold this session" — locks it against cancelling.
  Future<ApiResponse<Session>> confirmSession(int id) async {
    final res = await _dio.post(ApiEndpoints.confirmSession(id));
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => Session.fromJson(asMap(d)));
  }

  /// Multipart only when a justification file (image or PDF, 10 MB max) is attached.
  Future<ApiResponse<Object?>> cancelSession(
    int id, {
    required int reasonId,
    String? description,
    int? replacementTeacherId,
    String? replacementName,
    String? filePath,
  }) async {
    final fields = <String, dynamic>{
      'reason_id': reasonId,
      'description': ?description,
      'replacement_teacher_id': ?replacementTeacherId,
      'replacement_name': ?replacementName,
    };
    final res = await _dio.post(
      ApiEndpoints.cancelSession(id),
      data: filePath == null
          ? fields
          : FormData.fromMap({
              ...fields.map((k, v) => MapEntry(k, '$v')),
              'file': await MultipartFile.fromFile(filePath),
            }),
    );
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => d);
  }

  /// Colleagues who can be suggested as a replacement.
  Future<ApiResponse<List<TeacherRef>>> fetchTeacherDirectory({String? search}) async {
    final res = await _dio.get(ApiEndpoints.teacherDirectory, queryParameters: {'search': ?search});
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => asMapList(d).map(TeacherRef.fromJson).toList());
  }

  /// Ask the office to reopen a held session.
  Future<ApiResponse<EditRequest>> createEditRequest(int sessionId, {String? reason}) async {
    final res = await _dio.post(ApiEndpoints.editRequests(sessionId), data: {'reason': ?reason});
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => EditRequest.fromJson(asMap(d)));
  }

  Future<ApiResponse<List<EditRequest>>> fetchEditRequests(int sessionId) async {
    final res = await _dio.get(ApiEndpoints.editRequests(sessionId));
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => asMapList(d).map(EditRequest.fromJson).toList());
  }

  Future<ApiResponse<Object?>> withdrawEditRequest(int id) async {
    final res = await _dio.delete(ApiEndpoints.editRequest(id));
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => d);
  }

  Future<ApiResponse<PaymentSummary>> fetchPaymentSummary() async {
    final res = await _dio.get(ApiEndpoints.teacherPaymentsSummary, queryParameters: {'teacher_id': 'me'});
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => PaymentSummary.fromJson(asMap(d)));
  }

  /// Newest first; the envelope carries the page under `data.data`.
  Future<ApiResponse<List<TeacherPayment>>> fetchPayments() async {
    final res = await _dio.get(ApiEndpoints.teacherPayments, queryParameters: {'teacher_id': 'me'});
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      res.statusCode!,
      (d) => asMapList(d is Map ? d['data'] : d).map(TeacherPayment.fromJson).toList(),
    );
  }

  /// FCM registration token of this phone.
  Future<ApiResponse<Object?>> registerDevice(String token, {String? platform}) async {
    final res = await _dio.post(ApiEndpoints.devices, data: {'token': token, 'platform': ?platform});
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => d);
  }

  Future<ApiResponse<Object?>> unregisterDevice(String token) async {
    final res = await _dio.delete(ApiEndpoints.device(token));
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => d);
  }

  Future<ApiResponse<List<CancelReason>>> fetchCancelReasons() async {
    final res = await _dio.get(ApiEndpoints.cancelReasons);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => asMapList(d).map(CancelReason.fromJson).toList());
  }

  Future<ApiResponse<List<Room>>> fetchRooms() async {
    final res = await _dio.get(ApiEndpoints.rooms);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => asMapList(d).map(Room.fromJson).toList());
  }

  Future<ApiResponse<List<Book>>> fetchBooks() async {
    final res = await _dio.get(ApiEndpoints.books);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => asMapList(d).map(Book.fromJson).toList());
  }

  /// multipart: category code, description and/or one image, optional room.
  Future<ApiResponse<Object?>> sendReport({String? category, String? description, String? imagePath, int? roomId}) async {
    final form = FormData.fromMap({
      'category': ?category,
      'description': ?description,
      'room_id': ?roomId,
      if (imagePath != null) 'image': await MultipartFile.fromFile(imagePath),
    });
    final res = await _dio.post(ApiEndpoints.reports, data: form);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => d);
  }

  Future<ApiResponse<List<Session>>> fetchSessions({int? groupId}) async {
    final res = await _dio.get(ApiEndpoints.sessions, queryParameters: {
      'teacher_id': 'me',
      'group_id': ?groupId,
      'group_state': 'all', // history must still show a stopped group's sessions
    });
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      res.statusCode!,
      (data) => asMapList(data is Map ? data['sessions'] : data).map(Session.fromJson).toList(),
    );
  }

  Future<ApiResponse<Session>> fetchSession(int id) async {
    final res = await _dio.get(ApiEndpoints.session(id));
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => Session.fromJson(asMap(d)));
  }

  /// All-or-nothing on the backend.
  Future<ApiResponse<Object?>> saveAttendance(int sessionId, List<AttendanceWrite> records) async {
    final res = await _dio.post(
      ApiEndpoints.bulkAttendance(sessionId),
      data: {'records': records.map((r) => r.toJson()).toList()},
    );
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, res.statusCode!, (d) => d);
  }
}
