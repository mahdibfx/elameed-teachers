import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/empty_state.dart';
import 'package:teachers_app/ui/widgets/meta.dart';
import 'package:teachers_app/ui/widgets/status_pill.dart';

import 'student_attendance_viewmodel.dart';

class StudentAttendanceView extends StackedView<StudentAttendanceViewModel> {
  const StudentAttendanceView({super.key, required this.student, required this.group});

  final GroupStudent student;
  final Group group;

  @override
  Widget builder(BuildContext context, StudentAttendanceViewModel viewModel, Widget? child) {
    return AppPage(
      title: 'attendance.title'.tr(),
      onBack: viewModel.onBack,
      tabIndex: 2,
      onTabTap: viewModel.onTabTap,
      children: [
        DarkHeaderCard(children: [
          CustomText.titleSmall(text: student.name, textColor: Colors.white),
          const SizedBox(height: 4),
          SubtitleTag(subtitle: group.name, tag: group.teacherName, dark: true),
          if (student.age != null) ...[
            const SizedBox(height: 4),
            CustomText.bodySmall(text: 'student.age'.tr(args: ['${student.age}']), textColor: Colors.white70),
          ],
        ]),
        AsyncBody(
          isBusy: viewModel.isBusy,
          isEmpty: viewModel.records.isEmpty,
          emptyMessage: 'attendance.empty'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in viewModel.records)
                AppCard(
                  onTap: entry.feedback == null ? null : () => viewModel.onEvaluationTap(entry),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: DateLabel(entry.session.date)),
                          StatusPill.attendance(entry.present),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TimeRange(start: entry.session.start, end: entry.session.end),
                      if (entry.feedback != null) ...[
                        const SizedBox(height: 12),
                        CustomButton(
                          onPressed: () => viewModel.onEvaluationTap(entry),
                          text: 'attendance.view_evaluation'.tr(),
                          icon: Icons.format_list_bulleted,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void onViewModelReady(StudentAttendanceViewModel viewModel) => viewModel.init();

  @override
  StudentAttendanceViewModel viewModelBuilder(BuildContext context) =>
      StudentAttendanceViewModel(student: student, group: group);
}
