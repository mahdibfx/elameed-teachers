import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/custom_input.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/empty_state.dart';

import 'sessions_viewmodel.dart';
import 'widgets/session_card.dart';

class SessionsView extends StackedView<SessionsViewModel> {
  const SessionsView({super.key});

  @override
  Widget builder(BuildContext context, SessionsViewModel viewModel, Widget? child) {
    const r = Radius.circular(AppStyles.borderRadiusMediumValue);
    Widget dateField(String label, TextEditingController c, VoidCallback onTap, BorderRadius radius) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.bodySmall(text: label),
          const SizedBox(height: 6),
          CustomInput(
            controller: c,
            hintText: 'sessions.date_hint'.tr(),
            prefixIcon: Icons.calendar_today_outlined,
            onTap: onTap,
            borderRadius: radius,
          ),
        ],
      ),
    );

    final sections = viewModel.sections;
    return AppPage(
      title: 'sessions.title'.tr(),
      onRefresh: viewModel.init,
      top: Column(
        children: [
          _Tabs(upcoming: viewModel.showUpcoming, onChanged: viewModel.setTab),
          if (!viewModel.showUpcoming) ...[
            const SizedBox(height: 16),
            CustomInput.search(
              controller: viewModel.searchController,
              hintText: 'groups.search'.tr(),
              onChanged: viewModel.onSearchChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                dateField('sessions.from'.tr(), viewModel.fromController, viewModel.onFromTap, const BorderRadius.horizontal(left: r)),
                dateField('sessions.to'.tr(), viewModel.toController, viewModel.onToTap, const BorderRadius.horizontal(right: r)),
              ],
            ),
          ],
        ],
      ),
      children: [
        AsyncBody(
          isBusy: viewModel.isBusy,
          isEmpty: sections.isEmpty,
          emptyMessage: (viewModel.showUpcoming ? 'sessions.no_upcoming' : 'sessions.empty').tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (title, sessions) in sections) ...[
                SectionTitle(title),
                for (final s in sessions)
                  SessionCard(session: s, onTap: () => viewModel.onSessionTap(s), onCancel: () => viewModel.onCancelTap(s)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  void onViewModelReady(SessionsViewModel viewModel) => viewModel.init();

  @override
  SessionsViewModel viewModelBuilder(BuildContext context) => SessionsViewModel();
}

/// History | Upcoming switch on top of the list.
class _Tabs extends StatelessWidget {
  const _Tabs({required this.upcoming, required this.onChanged});

  final bool upcoming;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool value) => Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: upcoming == value ? AppColors.primaryColorLight : AppColors.surfaceColor,
          child: CustomText.bodyMedium(
            text: label,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w600,
            textColor: upcoming == value ? AppColors.primaryColor : AppColors.mutedColor,
          ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusMediumValue),
        border: Border.all(color: AppColors.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [tab('sessions.history'.tr(), false), tab('sessions.upcoming'.tr(), true)]),
    );
  }
}
