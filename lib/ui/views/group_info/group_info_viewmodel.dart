import 'package:easy_localization/easy_localization.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/ui/views/main/tab_navigation.dart';
import 'package:teachers_app/utils/formatters.dart';

class GroupInfoViewModel extends BaseViewModel with TabNavigation {
  GroupInfoViewModel(this.group);

  final _teacherService = locator<TeacherService>();
  final _snackbarService = locator<SnackbarService>();
  final Group group;

  List<Session> _sessions = [];
  List<GroupStudent> _students = [];
  bool sessionsExpanded = true;

  String get salaryType => group.salaryType == 'static' ? 'group_info.fixed'.tr() : group.salaryType;
  String get salaryAmount => 'common.da'.tr(args: [amount(group.salaryAmount.round())]);

  double get progress => group.plannedSessions == 0 ? 0 : (group.heldSessions / group.plannedSessions).clamp(0.0, 1.0);

  /// Where the group should be by now given its weekly schedule, drawn as the lighter bar segment.
  double get expectedProgress {
    final since = group.runningSince;
    if (since == null || group.plannedSessions == 0) return progress;
    final weeks = DateTime.now().difference(since).inDays / 7;
    return (weeks * group.sessionsPerWeek / group.plannedSessions).clamp(progress, 1.0);
  }

  bool get isLate => expectedProgress - progress > 1 / group.plannedSessions.clamp(1, 1000);
  String get standing => (isLate ? 'group_info.late' : 'group_info.on_track').tr();

  List<(String day, String time)> get schedule => [for (final s in group.schedule) (localDay(s.day), '${s.start} ~ ${s.end}')];

  /// "attended / marked" straight from the roster endpoint.
  List<(String name, String attendance)> get students => [for (final s in _students) (s.name, s.attendance)];

  List<Session> get sessions => _sessions;

  String sessionAttendance(Session s) => '${s.presentCount}/${s.attendanceCount}';

  Future<void> init() async {
    setBusy(true);
    final (sessions, students) = await (
      _teacherService.getSessions(groupId: group.id),
      _teacherService.getGroupStudents(group.id),
    ).wait;
    sessions.fold((f) => _snackbarService.showSnackbar(message: f.message), (s) {
      _sessions = s.where((x) => x.isHeld || x.attendanceCount > 0).toList(); // past sessions, as in the design
    });
    students.fold((f) => _snackbarService.showSnackbar(message: f.message), (s) => _students = s);
    setBusy(false);
  }

  void toggleSessions() {
    sessionsExpanded = !sessionsExpanded;
    notifyListeners();
  }

  Future<void> onSessionTap(Session s) async {
    await navigationService.navigateToSessionView(sessionId: s.id);
    await init();
  }
}
