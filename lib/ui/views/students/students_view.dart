import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_input.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/empty_state.dart';
import 'package:teachers_app/ui/widgets/meta.dart';

import 'students_viewmodel.dart';

class StudentsView extends StackedView<StudentsViewModel> {
  const StudentsView({super.key});

  @override
  Widget builder(BuildContext context, StudentsViewModel viewModel, Widget? child) {
    return AppPage(
      title: 'students.title'.tr(),
      onRefresh: viewModel.onRefresh,
      top: CustomInput.search(
        controller: viewModel.searchController,
        hintText: 'students.search'.tr(),
        onChanged: viewModel.onSearchChanged,
      ),
      children: [
        AsyncBody(
          isBusy: viewModel.isBusy,
          isEmpty: viewModel.students.isEmpty,
          emptyMessage: 'students.empty'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final summary in viewModel.students)
                AppCard(
                  onTap: () => viewModel.onStudentTap(summary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText.titleSmall(text: summary.student.name),
                      const SizedBox(height: 4),
                      MetaRow([
                        MetaItem(
                          Icons.calendar_today_outlined,
                          summary.percentage == null
                              ? 'students.no_attendance'.tr()
                              : 'students.attendance'.tr(args: ['${summary.percentage}']),
                        ),
                        MetaItem(Icons.folder_copy_outlined, 'students.groups'.tr(args: ['${summary.groups.length}'])),
                      ]),
                      const SizedBox(height: 14),
                      CustomButton(onPressed: () => viewModel.onStudentTap(summary), text: 'students.view'.tr(), icon: Icons.badge_outlined),
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
  void onViewModelReady(StudentsViewModel viewModel) => viewModel.init();

  @override
  StudentsViewModel viewModelBuilder(BuildContext context) => StudentsViewModel();
}
