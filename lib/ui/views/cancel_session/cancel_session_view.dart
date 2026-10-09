import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/attachment_field.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_input.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/empty_state.dart';
import 'package:teachers_app/ui/widgets/option_tile.dart';
import 'package:teachers_app/ui/widgets/session_header_card.dart';

import 'cancel_session_viewmodel.dart';

class CancelSessionView extends StackedView<CancelSessionViewModel> {
  const CancelSessionView({super.key, required this.session});

  final Session session;

  @override
  Widget builder(BuildContext context, CancelSessionViewModel viewModel, Widget? child) {
    return AppPage(
      title: 'cancel.title'.tr(),
      onBack: viewModel.onBack,
      tabIndex: 1,
      onTabTap: viewModel.onTabTap,
      children: [
        SessionHeaderCard(session: session),
        SectionTitle('cancel.reason'.tr()),
        AsyncBody(
          isBusy: viewModel.isBusy,
          isEmpty: viewModel.reasons.isEmpty,
          emptyMessage: 'cancel.no_reasons'.tr(),
          child: Column(
            children: [
              for (final r in viewModel.reasons)
                OptionTile(
                  icon: _reasonIcon(r.name),
                  label: r.name,
                  selected: viewModel.reason?.id == r.id,
                  onTap: () => viewModel.onReasonTap(r),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SectionTitle('session.note'.tr()),
        CustomInput(controller: viewModel.noteController, hintText: 'cancel.note_hint'.tr(), minLines: 3),
        const SizedBox(height: 20),
        SectionTitle('cancel.replacement'.tr()),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomText.bodySmall(text: 'cancel.replacement_hint'.tr(), maxLines: 2),
        ),
        CustomInput(
          controller: viewModel.replacementController,
          hintText: 'cancel.teacher_name'.tr(),
          prefixIcon: Icons.search,
          onChanged: viewModel.onReplacementChanged,
        ),
        // Suggestions from the teacher directory; picking one sends their id.
        if (viewModel.matches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                for (final t in viewModel.matches)
                  Material(
                    color: AppColors.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmallValue),
                      side: const BorderSide(color: AppColors.borderColor),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.person_outline, color: AppColors.secondaryColor),
                      title: CustomText.bodyMedium(text: t.name),
                      onTap: () => viewModel.onReplacementPicked(t),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        OptionTile(label: 'cancel.no_replacement'.tr(), selected: viewModel.noReplacement, onTap: viewModel.onNoReplacementTap),
        const SizedBox(height: 12),
        SectionTitle('cancel.justification'.tr()),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomText.bodySmall(text: 'cancel.justification_hint'.tr(), maxLines: 2),
        ),
        AttachmentField(
          path: viewModel.filePath,
          allowPdf: true,
          onPick: viewModel.onFilePicked,
          onRemove: viewModel.onRemoveFile,
        ),
        const SizedBox(height: 20),
        CustomButton.submit(onPressed: viewModel.onSubmit, text: 'cancel.submit'.tr(), icon: Icons.check, isLoading: viewModel.isSaving),
      ],
    );
  }

  /// The reasons are office-managed free text; match the usual ones to the design's icons.
  static IconData _reasonIcon(String name) {
    final n = name.toLowerCase();
    for (final (pattern, icon) in _icons) {
      if (RegExp(pattern).hasMatch(n)) return icon;
    }
    return Icons.more_horiz;
  }

  // Matched against the live list (Teacher sick, Bad weather, Power cut, …) plus the design's own.
  static const _icons = [
    ('sick|malad|مرض', Icons.thermostat_outlined),
    ('famil|عائل', Icons.family_restroom_outlined),
    ('transport|نقل', Icons.directions_bus_outlined),
    ('emergen|urgen|طوار', Icons.emergency_outlined),
    ('weather|météo|طقس', Icons.cloud_outlined),
    ('exam|امتحان', Icons.school_outlined),
    ('closed|fermé|مغلق', Icons.lock_outline),
    ('internet|technical|technique', Icons.wifi_off),
    ('power|électri|كهرباء', Icons.power_off_outlined),
    ('holiday|férié|عطلة', Icons.celebration_outlined),
    ('reschedul|report', Icons.event_repeat),
    ('room|salle|قاعة', Icons.meeting_room_outlined),
    ('student|élève|طلاب', Icons.groups_outlined),
    ('absent|غياب', Icons.person_off_outlined),
  ];

  @override
  void onViewModelReady(CancelSessionViewModel viewModel) => viewModel.init();

  @override
  CancelSessionViewModel viewModelBuilder(BuildContext context) => CancelSessionViewModel(session);
}
