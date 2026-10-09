import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/ui/views/main/tab_navigation.dart';

class StudentAttendanceViewModel extends BaseViewModel with TabNavigation {
  StudentAttendanceViewModel({required this.student, required this.group});

  final _teacherService = locator<TeacherService>();
  final _snackbarService = locator<SnackbarService>();
  final GroupStudent student;
  final Group group;

  /// Marked sessions of this student in this group, newest first.
  List<AttendanceEntry> records = [];

  Future<void> init() async {
    setBusy(true);
    final result = await _teacherService.getStudentAttendance(student.id, groupId: group.id);
    result.fold((f) => _snackbarService.showSnackbar(message: f.message), (r) => records = r);
    setBusy(false);
  }

  void onEvaluationTap(AttendanceEntry entry) => navigationService.navigateToEvaluationView(
        session: entry.session,
        studentName: student.name,
        evaluation: entry.feedback,
        readOnly: true,
      );
}
