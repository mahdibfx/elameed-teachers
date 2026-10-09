import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';

class GroupsViewModel extends BaseViewModel {
  final _teacherService = locator<TeacherService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final searchController = TextEditingController();

  List<Group> _groups = [];

  List<Group> get _filtered {
    final q = searchController.text.trim().toLowerCase();
    return q.isEmpty ? _groups : _groups.where((g) => g.name.toLowerCase().contains(q)).toList();
  }

  List<Group> get running => _filtered.where((g) => g.isRunning).toList();
  List<Group> get stopped => _filtered.where((g) => !g.isRunning).toList();

  Future<void> init({bool refresh = false}) async {
    setBusy(_groups.isEmpty);
    final result = await _teacherService.getGroups(refresh: refresh);
    result.fold((f) => _snackbarService.showSnackbar(message: f.message), (g) => _groups = g);
    setBusy(false);
  }

  Future<void> onRefresh() => init(refresh: true);

  void onSearchChanged(String _) => notifyListeners();

  void onGroupTap(Group g) => _navigationService.navigateToGroupInfoView(group: g);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
