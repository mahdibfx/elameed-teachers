import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/widgets/empty_state.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/group_card.dart';
import 'package:teachers_app/ui/widgets/meta.dart';

import 'student_info_viewmodel.dart';

class StudentInfoView extends StackedView<StudentInfoViewModel> {
  const StudentInfoView({super.key, required this.student});

  final GroupStudent student;

  @override
  Widget builder(BuildContext context, StudentInfoViewModel viewModel, Widget? child) {
    final sections = [
      ('student.running_groups', viewModel.runningGroups),
      ('student.completed_groups', viewModel.completedGroups),
    ];
    return AppPage(
      title: 'student.title'.tr(),
      onBack: viewModel.onBack,
      tabIndex: 2,
      onTabTap: viewModel.onTabTap,
      children: [
        DarkHeaderCard(children: [
          CustomText.titleSmall(text: viewModel.student.name, textColor: Colors.white),
          const SizedBox(height: 4),
          SubtitleTag(
            subtitle: student.age == null ? student.phone : 'student.age'.tr(args: ['${student.age}']),
            tag: student.age == null ? '' : student.phone,
            dark: true,
          ),
        ]),
        if (viewModel.isBusy) const AsyncBody(isBusy: true, isEmpty: false, emptyMessage: '', child: SizedBox.shrink()),
        for (final (title, groups) in sections)
          if (groups.isNotEmpty) ...[
            SectionTitle(title.tr()),
            for (final g in groups)
              GroupCard(
                group: g,
                subtitle: g.courseName,
                tag: g.teacherName,
                period: viewModel.period(g),
                buttonText: 'student.view_attendance'.tr(),
                buttonIcon: Icons.badge_outlined,
                onTap: () => viewModel.onGroupTap(g),
              ),
          ],
      ],
    );
  }

  @override
  StudentInfoViewModel viewModelBuilder(BuildContext context) => StudentInfoViewModel(student);

  @override
  void onViewModelReady(StudentInfoViewModel viewModel) => viewModel.init();
}
