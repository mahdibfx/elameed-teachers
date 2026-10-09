import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/ui/views/main/tab_navigation.dart';

class CancelSessionViewModel extends BaseViewModel with TabNavigation {
  CancelSessionViewModel(this.session);

  final Session session;
  final _teacherService = locator<TeacherService>();
  final _snackbarService = locator<SnackbarService>();
  final noteController = TextEditingController();
  final replacementController = TextEditingController();

  List<CancelReason> reasons = [];
  CancelReason? reason;
  bool isSaving = false;
  String? filePath;

  /// Colleagues matching what was typed; empty until the teacher types.
  List<TeacherRef> matches = [];
  TeacherRef? replacement;

  bool get noReplacement => replacement == null && replacementController.text.trim().isEmpty;

  Future<void> init() async {
    setBusy(true);
    final result = await _teacherService.getCancelReasons();
    result.fold((f) => _snackbarService.showSnackbar(message: f.message), (r) => reasons = r);
    setBusy(false);
  }

  void onFilePicked(String path) {
    filePath = path;
    notifyListeners();
  }

  void onRemoveFile() {
    filePath = null;
    notifyListeners();
  }

  void onReasonTap(CancelReason r) {
    reason = r;
    notifyListeners();
  }

  /// Typing searches the teacher directory; picking a name sends their id instead of free text.
  Future<void> onReplacementChanged(String value) async {
    replacement = null;
    final query = value.trim();
    notifyListeners();
    if (query.length < 2) {
      matches = [];
      notifyListeners();
      return;
    }
    final result = await _teacherService.getTeacherDirectory(search: query);
    // Ignore a late answer for a query the teacher already changed.
    if (query != replacementController.text.trim()) return;
    result.fold((_) => matches = [], (list) => matches = list.take(6).toList());
    notifyListeners();
  }

  void onReplacementPicked(TeacherRef t) {
    replacement = t;
    replacementController.text = t.name;
    matches = [];
    notifyListeners();
  }

  void onNoReplacementTap() {
    replacementController.clear();
    replacement = null;
    matches = [];
    notifyListeners();
  }

  Future<void> onSubmit() async {
    if (isSaving) return;
    if (reason == null) {
      _snackbarService.showSnackbar(message: 'cancel.pick_reason'.tr(), duration: const Duration(seconds: 2));
      return;
    }
    final description = noteController.text.trim();
    final typedName = replacementController.text.trim();

    isSaving = true;
    notifyListeners();
    final result = await _teacherService.cancelSession(
      session.id,
      reasonId: reason!.id,
      description: description.isEmpty ? null : description,
      replacementTeacherId: replacement?.id,
      // Free text only when the suggestion isn't a colleague from the directory.
      replacementName: replacement == null && typedName.isNotEmpty ? typedName : null,
      filePath: filePath,
    );
    isSaving = false;
    notifyListeners();
    result.fold((f) => _snackbarService.showSnackbar(message: f.message, duration: const Duration(seconds: 3)), (_) {
      _snackbarService.showSnackbar(message: 'cancel.done'.tr(), duration: const Duration(seconds: 2));
      navigationService.back(result: true);
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    replacementController.dispose();
    super.dispose();
  }
}
