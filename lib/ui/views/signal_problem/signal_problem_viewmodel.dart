import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/services/teacher_service.dart';
import 'package:teachers_app/ui/views/main/tab_navigation.dart';

class SignalProblemViewModel extends BaseViewModel with TabNavigation {
  SignalProblemViewModel(this.session);

  final Session session;
  final _teacherService = locator<TeacherService>();
  final _snackbarService = locator<SnackbarService>();
  final noteController = TextEditingController();

  /// The design's list; each one is also the API's `category` code.
  static const problems = ['whiteboard', 'dirty_room', 'broken_equipment', 'missing_equipment', 'furniture', 'other'];

  String? problem;
  String? imagePath;
  bool isSaving = false;

  void onProblemTap(String p) {
    problem = p;
    notifyListeners();
  }

  void onImagePicked(String path) {
    imagePath = path;
    notifyListeners();
  }

  void onRemoveImage() {
    imagePath = null;
    notifyListeners();
  }

  Future<void> onSubmit() async {
    if (isSaving) return;
    if (problem == null) {
      _snackbarService.showSnackbar(message: 'problem.pick'.tr(), duration: const Duration(seconds: 2));
      return;
    }
    isSaving = true;
    notifyListeners();
    final result = await _teacherService.sendReport(
      category: problem,
      description: noteController.text.trim(),
      imagePath: imagePath,
      roomId: session.room?.id,
    );
    isSaving = false;
    notifyListeners();
    result.fold((f) => _snackbarService.showSnackbar(message: f.message, duration: const Duration(seconds: 3)), (_) {
      _snackbarService.showSnackbar(message: 'problem.sent'.tr(), duration: const Duration(seconds: 2));
      navigationService.back();
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
