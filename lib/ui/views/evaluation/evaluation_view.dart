import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/choice_toggle.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_input.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';
import 'package:teachers_app/ui/widgets/session_header_card.dart';
import 'package:teachers_app/utils/formatters.dart';

import 'evaluation_viewmodel.dart';
import 'widgets/evaluation_controls.dart';

/// Editable from the Session screen; [readOnly] from a student's attendance history.
class EvaluationView extends StackedView<EvaluationViewModel> {
  const EvaluationView({super.key, required this.session, required this.studentName, this.evaluation, this.readOnly = false});

  final Session session;
  final String studentName;
  final Evaluation? evaluation;
  final bool readOnly;

  @override
  Widget builder(BuildContext context, EvaluationViewModel viewModel, Widget? child) {
    final e = viewModel.evaluation;
    // null callbacks make every control inert in read-only mode.
    T? edit<T>(T callback) => readOnly ? null : callback;

    return AppPage(
      title: (readOnly ? 'evaluation.session_title' : 'evaluation.title').tr(),
      onBack: viewModel.onBack,
      tabIndex: readOnly ? 2 : 1,
      onTabTap: viewModel.onTabTap,
      children: [
        if (readOnly)
          DarkHeaderCard(children: [
            CustomText.titleSmall(text: studentName, textColor: Colors.white),
            const SizedBox(height: 4),
            CustomText.bodySmall(text: session.groupName, textColor: Colors.white70),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: CustomText.bodySmall(text: fullDate(session.date), textColor: Colors.white, fontWeight: FontWeight.w700)),
                CustomText.bodySmall(text: timeRange(session.start, session.end), textColor: Colors.white, fontWeight: FontWeight.w700),
              ],
            ),
          ])
        else
          SessionHeaderCard(
            session: session,
            studentName: studentName,
            fields: [
              IconField(
                icon: Icons.description_outlined,
                label: 'session.note'.tr(),
                child: CustomText(
                  session.notes.isEmpty ? 'session.no_note'.tr() : session.notes,
                  fontSize: 16,
                  textColor: session.notes.isEmpty ? AppColors.mutedColor : AppColors.textColor,
                ),
              ),
            ],
          ),
        SectionTitle('evaluation.student_evaluation'.tr()),
        EvaluationSection(title: 'evaluation.attendance'.tr(), children: [
          FieldLabel('evaluation.arrival'.tr()),
          ChoiceToggle(
            selected: e.onTime ? 0 : 1,
            onChanged: edit(viewModel.setOnTime),
            options: [
              ToggleOption('evaluation.on_time'.tr(), AppColors.greenColor),
              ToggleOption('evaluation.late'.tr(), AppColors.redColor),
            ],
          ),
          const SizedBox(height: 8),
          FieldLabel('evaluation.departure'.tr()),
          ChoiceToggle(
            selected: e.leftEarly ? 1 : 0,
            onChanged: edit(viewModel.setLeftEarly),
            options: [
              ToggleOption('evaluation.normal'.tr(), AppColors.greenColor),
              ToggleOption('evaluation.left_early'.tr(), AppColors.redColor),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: !e.leftEarly
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CustomInput(
                      controller: viewModel.leavingTimeController,
                      hintText: 'evaluation.leaving_time_hint'.tr(),
                      suffixIcon: Icons.timer_outlined,
                      onTap: edit(viewModel.onLeavingTimeTap),
                      readOnly: readOnly,
                    ),
                  ),
          ),
        ]),
        EvaluationSection(title: 'evaluation.understanding'.tr(), children: [
          FieldLabel('evaluation.understanding_question'.tr()),
          StepScale(options: viewModel.understandingOptions, selected: e.understanding - 1, onChanged: edit(viewModel.setUnderstanding)),
        ]),
        EvaluationSection(title: 'evaluation.concentration_engagement'.tr(), children: [
          FieldLabel('evaluation.concentration'.tr()),
          StepScale(options: viewModel.oneToFiveOptions, selected: e.concentration - 1, onChanged: edit(viewModel.setConcentration)),
          FieldLabel('evaluation.engagement'.tr()),
          StepScale(options: viewModel.oneToFiveOptions, selected: e.engagement - 1, onChanged: edit(viewModel.setEngagement)),
        ]),
        EvaluationSection(title: 'evaluation.homework_next'.tr(), children: [
          FieldLabel('evaluation.homework'.tr()),
          SelectChips(labels: viewModel.homeworkOptions, isSelected: viewModel.isHomework, onTap: edit(viewModel.setHomework)),
          FieldLabel('evaluation.next_step'.tr()),
          SelectChips(labels: viewModel.nextStepOptions, isSelected: viewModel.isNextStep, onTap: edit(viewModel.setNextStep)),
        ]),
        EvaluationSection(title: 'evaluation.behavior_note'.tr(), children: [
          FieldLabel('evaluation.behavior'.tr()),
          StepScale(options: viewModel.behaviorOptions, selected: e.behavior, onChanged: edit(viewModel.setBehavior)),
          FieldLabel('evaluation.note'.tr()),
          CustomInput(controller: viewModel.noteController, hintText: 'evaluation.note_hint'.tr(), minLines: 4, readOnly: readOnly),
        ]),
        if (!readOnly)
          CustomButton.submit(onPressed: viewModel.onSubmit, text: 'evaluation.submit'.tr(), icon: Icons.checklist),
      ],
    );
  }

  @override
  EvaluationViewModel viewModelBuilder(BuildContext context) =>
      EvaluationViewModel(session: session, studentName: studentName, evaluation: evaluation, readOnly: readOnly);
}
