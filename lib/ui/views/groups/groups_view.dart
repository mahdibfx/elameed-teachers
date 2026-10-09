import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/custom_input.dart';
import 'package:teachers_app/ui/widgets/empty_state.dart';
import 'package:teachers_app/ui/widgets/group_card.dart';

import 'groups_viewmodel.dart';

class GroupsView extends StackedView<GroupsViewModel> {
  const GroupsView({super.key});

  @override
  Widget builder(BuildContext context, GroupsViewModel viewModel, Widget? child) {
    final sections = [('groups.running', viewModel.running), ('groups.stopped', viewModel.stopped)];
    return AppPage(
      title: 'groups.title'.tr(),
      onRefresh: viewModel.onRefresh,
      top: CustomInput.search(
        controller: viewModel.searchController,
        hintText: 'groups.search'.tr(),
        onChanged: viewModel.onSearchChanged,
      ),
      children: [
        AsyncBody(
          isBusy: viewModel.isBusy,
          isEmpty: viewModel.running.isEmpty && viewModel.stopped.isEmpty,
          emptyMessage: 'groups.empty'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (title, groups) in sections)
                if (groups.isNotEmpty) ...[
                  SectionTitle(title.tr()),
                  for (final g in groups)
                    GroupCard(
                      group: g,
                      subtitle: g.courseName,
                      tag: '',
                      buttonText: 'groups.view'.tr(),
                      buttonIcon: Icons.folder_copy_outlined,
                      onTap: () => viewModel.onGroupTap(g),
                    ),
                ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  void onViewModelReady(GroupsViewModel viewModel) => viewModel.init();

  @override
  GroupsViewModel viewModelBuilder(BuildContext context) => GroupsViewModel();
}
