import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/views/main/tab_navigation.dart';

/// Edits a copy of the student's feedback; Submit hands it back to the Session
/// screen, which saves it with the attendance in one bulk call.
class EvaluationViewModel extends BaseViewModel with TabNavigation {
  EvaluationViewModel({required this.session, required this.studentName, required Evaluation? evaluation, required this.readOnly})
      : evaluation = evaluation?.copy() ?? Evaluation() {
    leavingTimeController.text = this.evaluation.leavingTime;
    noteController.text = this.evaluation.note;
  }

  final Session session;
  final String studentName;
  final bool readOnly;
  final Evaluation evaluation;
  final leavingTimeController = TextEditingController();
  final noteController = TextEditingController();

  static const _scale = [
    AppColors.scaleVeryWeak,
    AppColors.scaleWeak,
    AppColors.scaleAverage,
    AppColors.scaleGood,
    AppColors.scaleExcellent,
  ];

  // API wire values, in display order.
  static const homeworkKeys = ['done', 'partial', 'not_done', 'no_homework'];
  static const nextStepKeys = ['review', 'practice', 'participate_more', 'improve_concentration', 'nothing_specific'];

  List<(String, Color)> get understandingOptions => [
        for (final (i, k) in ['very_weak', 'weak', 'average', 'good', 'excellent'].indexed) ('evaluation.$k'.tr(), _scale[i]),
      ];

  List<(String, Color)> get oneToFiveOptions => [for (var i = 0; i < 5; i++) ('${i + 1}', _scale[i])];

  List<(String, Color)> get behaviorOptions => [
        ('evaluation.no_issue'.tr(), AppColors.scaleExcellent),
        ('evaluation.minor'.tr(), AppColors.scaleAverage),
        ('evaluation.noticeable'.tr(), AppColors.scaleWeak),
        ('evaluation.serious'.tr(), AppColors.scaleVeryWeak),
      ];

  List<String> get homeworkOptions => [for (final k in homeworkKeys) 'evaluation.$k'.tr()];
  List<String> get nextStepOptions => [for (final k in nextStepKeys) 'evaluation.$k'.tr()];

  bool isHomework(int i) => evaluation.homework == homeworkKeys[i];
  bool isNextStep(int i) => evaluation.nextStep == nextStepKeys[i];

  void _set(VoidCallback change) {
    if (readOnly) return;
    change();
    notifyListeners();
  }

  // Scales are 1-based on the wire, 0-based on screen.
  void setOnTime(int i) => _set(() => evaluation.onTime = i == 0);
  void setLeftEarly(int i) => _set(() => evaluation.leftEarly = i == 1);
  void setUnderstanding(int i) => _set(() => evaluation.understanding = i + 1);
  void setConcentration(int i) => _set(() => evaluation.concentration = i + 1);
  void setEngagement(int i) => _set(() => evaluation.engagement = i + 1);
  void setHomework(int i) => _set(() => evaluation.homework = homeworkKeys[i]);
  void setBehavior(int i) => _set(() => evaluation.behavior = i);

  /// Single choice on the API; tapping the selected chip clears it.
  void setNextStep(int i) => _set(() => evaluation.nextStep = isNextStep(i) ? null : nextStepKeys[i]);

  Future<void> onLeavingTimeTap() async {
    if (readOnly) return;
    final t = await showTimePicker(context: StackedService.navigatorKey!.currentContext!, initialTime: TimeOfDay.now());
    if (t == null) return;
    leavingTimeController.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    evaluation.leavingTime = leavingTimeController.text;
  }

  void onSubmit() {
    evaluation.note = noteController.text.trim();
    if (!evaluation.leftEarly) evaluation.leavingTime = '';
    navigationService.back(result: evaluation);
  }

  @override
  void dispose() {
    leavingTimeController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
