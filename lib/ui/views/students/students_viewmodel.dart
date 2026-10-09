import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';

class StudentsViewModel extends BaseViewModel {
  final _teacherService = locator<TeacherService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final searchController = TextEditingController();

  List<StudentSummary> _students = [];

  List<StudentSummary> get students {
    final q = searchController.text.trim().toLowerCase();
    return q.isEmpty ? _students : _students.where((s) => s.student.name.toLowerCase().contains(q)).toList();
  }

  Future<void> init({bool refresh = false}) async {
    setBusy(_students.isEmpty);
    final result = await _teacherService.getStudents();
    result.fold(
      (f) => _snackbarService.showSnackbar(message: f.message),
      (s) => _students = s..sort((a, b) => a.student.name.compareTo(b.student.name)),
    );
    setBusy(false);
  }

  Future<void> onRefresh() => init(refresh: true);

  void onSearchChanged(String _) => notifyListeners();

  void onStudentTap(StudentSummary s) => _navigationService.navigateToStudentInfoView(student: s.student);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
