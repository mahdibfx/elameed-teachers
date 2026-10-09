import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';
import 'package:teachers_app/ui/widgets/status_pill.dart';

import 'group_info_viewmodel.dart';
import 'widgets/group_session_card.dart';
import 'widgets/info_card.dart';

class GroupInfoView extends StackedView<GroupInfoViewModel> {
  const GroupInfoView({super.key, required this.group});

  final Group group;

  @override
  Widget builder(BuildContext context, GroupInfoViewModel viewModel, Widget? child) {
    final g = viewModel.group;
    final meta = groupMetaItems(g);
    return AppPage(
      title: 'group_info.title'.tr(),
      onBack: viewModel.onBack,
      tabIndex: 0,
      onTabTap: viewModel.onTabTap,
      children: [
        DarkHeaderCard(children: [
          Row(
            children: [
              Expanded(child: CustomText.titleSmall(text: g.name, textColor: Colors.white)),
              if (g.isRunning) StatusPill.running(),
            ],
          ),
          const SizedBox(height: 4),
          SubtitleTag(subtitle: g.courseName, dark: true),
          const SizedBox(height: 4),
          MetaRow(meta, dark: true),
        ]),
        InfoCard(title: 'group_info.payment'.tr(), children: [
          InfoRow('group_info.plan'.tr(), viewModel.salaryType),
          InfoRow('group_info.total_amount'.tr(), viewModel.salaryAmount, valueColor: AppColors.greenColor),
        ]),
        InfoCard(title: 'group_info.progress'.tr(), meta: meta[2], children: [
          ProgressBar(done: viewModel.progress, expected: viewModel.expectedProgress),
          InfoRow('group_info.standing'.tr(), viewModel.standing),
        ]),
        InfoCard(title: 'group_info.schedule'.tr(), meta: meta[1], children: [
          for (final (day, time) in viewModel.schedule) InfoRow(day, time),
        ]),
        InfoCard(title: 'group_info.students'.tr(), meta: meta[0], children: [
          InfoRow('group_info.student_name'.tr(), 'group_info.attendance'.tr(), bold: true),
          for (final (name, attendance) in viewModel.students) InfoRow(name, attendance),
        ]),
        GestureDetector(
          onTap: viewModel.toggleSessions,
          behavior: HitTestBehavior.opaque,
          child: SectionTitle(
            'group_info.sessions'.tr(),
            trailing: AnimatedRotation(
              turns: viewModel.sessionsExpanded ? 0 : -.25,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryColor),
            ),
          ),
        ),
        if (viewModel.isBusy)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
          ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: !viewModel.sessionsExpanded
              ? const SizedBox(width: double.infinity)
              : Column(
                  children: [
                    for (final s in viewModel.sessions)
                      GroupSessionCard(
                        session: s,
                        attendance: viewModel.sessionAttendance(s),
                        onTap: () => viewModel.onSessionTap(s),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  void onViewModelReady(GroupInfoViewModel viewModel) => viewModel.init();

  @override
  GroupInfoViewModel viewModelBuilder(BuildContext context) => GroupInfoViewModel(group);
}
