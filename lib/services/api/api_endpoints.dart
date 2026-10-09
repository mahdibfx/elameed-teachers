class ApiEndpoints {
  static const String base = 'https://backendelameed.onrender.com';

  // Auth
  static const String login = '/Auth/login';
  static const String verifyToken = '/Token/verifyToken';

  // Groups
  static const String groupsSchedules = '/groups/schedules';
  static String group(Object id) => '/groups/$id';
  static String groupStudents(Object id) => '/groups/$id/students';

  // Students
  static const String students = '/students';
  static String studentAttendance(Object id) => '/students/$id/attendance';

  // Sessions
  static const String sessions = '/sessions';
  static String session(Object id) => '/sessions/$id';
  static String bulkAttendance(Object id) => '/sessions/$id/attendance/bulk';
  static String confirmSession(Object id) => '/sessions/$id/confirm';
  static String cancelSession(Object id) => '/sessions/$id/cancel';
  static const String cancelReasons = '/session-cancel-reasons';
  static String editRequests(Object id) => '/sessions/$id/edit-requests';
  static String editRequest(Object id) => '/session-edit-requests/$id';

  // Teacher
  static const String teacherDirectory = '/teacher/directory';
  static const String teacherPayments = '/teacher-payments';
  static const String teacherPaymentsSummary = '/teacher-payments/summary';

  // Push
  static const String devices = '/devices';
  static String device(String token) => '/devices/${Uri.encodeComponent(token)}';

  static const String rooms = '/rooms';
  static const String books = '/language-books';
  static const String reports = '/reports';
}
