import 'package:easy_localization/easy_localization.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/ui/views/main/tab_navigation.dart';
import 'package:teachers_app/utils/formatters.dart';

class StudentInfoViewModel extends BaseViewModel with TabNavigation {
  StudentInfoViewModel(this.student);

  final _teacherService = locator<TeacherService>();
  final _snackbarService = locator<SnackbarService>();
  final GroupStudent student;

  List<Group> _groups = [];
  List<Group> get runningGroups => _groups.where((g) => g.isRunning).toList();
  List<Group> get completedGroups => _groups.where((g) => !g.isRunning).toList();

  Future<void> init() async {
    setBusy(true);
    final result = await _teacherService.groupsOf(student.id);
    result.fold((f) => _snackbarService.showSnackbar(message: f.message), (g) => _groups = g);
    setBusy(false);
  }

  /// "09/19/2025 ~ 10/25/2025", or "~ ongoing" while the group runs.
  String? period(Group g) {
    if (g.runningSince == null) return null;
    final end = g.stoppedAt == null ? 'student.ongoing'.tr() : shortDate(g.stoppedAt!);
    return '${shortDate(g.runningSince!)} ~ $end';
  }

  void onGroupTap(Group g) => navigationService.navigateToStudentAttendanceView(student: student, group: g);
}
