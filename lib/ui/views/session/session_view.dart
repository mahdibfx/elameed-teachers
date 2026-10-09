import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_input.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/empty_state.dart';
import 'package:teachers_app/ui/widgets/session_header_card.dart';

import 'session_viewmodel.dart';
import 'widgets/attendance_row.dart';

class SessionView extends StackedView<SessionViewModel> {
  const SessionView({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget builder(BuildContext context, SessionViewModel viewModel, Widget? child) {
    final session = viewModel.session;
    return AppPage(
      title: 'session.title'.tr(),
      onBack: viewModel.onBack,
      tabIndex: 1,
      onTabTap: viewModel.onTabTap,
      children: [
        AsyncBody(
          isBusy: viewModel.isBusy,
          isEmpty: session == null,
          emptyMessage: 'session.not_found'.tr(),
          child: session == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SessionHeaderCard(
                      session: session,
                      onHistoryTap: viewModel.onGroupHistoryTap,
                      actions: [
                        const SizedBox(height: 16),
                        if (viewModel.canConfirm) ...[
                          CustomButton(
                            onPressed: viewModel.onConfirmTap,
                            text: 'session.confirm'.tr(),
                            icon: Icons.how_to_reg_outlined,
                            color: AppColors.greenColor,
                            isLoading: viewModel.isConfirming,
                          ),
                          const SizedBox(height: 10),
                        ],
                        CustomButton(
                          onPressed: viewModel.onSignalProblemTap,
                          text: 'problem.title'.tr(),
                          icon: Icons.error_outline,
                          color: AppColors.redColor,
                        ),
                        if (viewModel.canEdit) ...[
                          const SizedBox(height: 10),
                          CustomButton(
                            onPressed: viewModel.onChangeRoomTap,
                            text: 'session.change_room'.tr(),
                            icon: Icons.door_front_door_outlined,
                            isLoading: viewModel.isChangingRoom,
                          ),
                        ],
                      ],
                      fields: [
                        // Editable until staff close the session (PATCH /sessions/:id).
                        IconField(
                          icon: Icons.menu_book_outlined,
                          label: 'session.unit'.tr(),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: viewModel.onUnitTap,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: CustomText(
                                viewModel.unitLabel.isNotEmpty
                                    ? viewModel.unitLabel
                                    : (viewModel.canEdit ? 'session.unit_hint' : 'session.no_unit').tr(),
                                fontSize: 16,
                                textColor: viewModel.unitLabel.isNotEmpty ? AppColors.textColor : AppColors.mutedColor,
                              ),
                            ),
                          ),
                        ),
                        IconField(
                          icon: Icons.description_outlined,
                          label: 'session.note'.tr(),
                          child: InlineInput(
                            controller: viewModel.noteController,
                            hintText: viewModel.canEdit ? 'session.note_hint'.tr() : 'session.no_note'.tr(),
                            readOnly: !viewModel.canEdit,
                          ),
                        ),
                      ],
                    ),
                    SectionTitle('session.attendance'.tr()),
                    if (!viewModel.canEdit) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomText.bodySmall(
                          text: (viewModel.inStoppedGroup ? 'session.group_stopped' : 'session.locked').tr(),
                          maxLines: 3,
                        ),
                      ),
                      if (viewModel.editRequest != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(child: CustomText.bodySmall(text: 'edit_request.waiting'.tr(), maxLines: 2)),
                              TextButton(
                                onPressed: viewModel.isAsking ? null : viewModel.onWithdrawEditRequest,
                                child: CustomText.bodyMedium(text: 'edit_request.withdraw'.tr(), textColor: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        )
                      else if (viewModel.canAskToEdit && !viewModel.inStoppedGroup)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomButton(
                            onPressed: () => _askToEdit(context, viewModel),
                            text: 'edit_request.ask'.tr(),
                            icon: Icons.lock_open_outlined,
                            isLoading: viewModel.isAsking,
                          ),
                        ),
                    ],
                    for (final a in viewModel.attendees)
                      AttendanceRow(
                        name: a.name,
                        selected: viewModel.attendanceIndex(a),
                        evaluated: viewModel.isEvaluated(a),
                        readOnly: !viewModel.canEdit,
                        onChanged: (i) => viewModel.onAttendanceChanged(a, i),
                        onEvaluationTap: () => viewModel.onEvaluationTap(a),
                        onHistoryTap: () => viewModel.onStudentHistoryTap(a),
                      ),
                    if (viewModel.canEdit)
                      CustomButton.submit(
                        onPressed: viewModel.onSubmit,
                        text: (viewModel.alreadyMarked ? 'session.save' : 'session.submit').tr(),
                        icon: viewModel.alreadyMarked ? Icons.save_outlined : Icons.badge_outlined,
                        isLoading: viewModel.isSaving,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  /// One short dialog for the optional reason the office will read.
  Future<void> _askToEdit(BuildContext context, SessionViewModel viewModel) async {
    final controller = TextEditingController();
    final send = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: CustomText.titleSmall(text: 'edit_request.ask'.tr()),
        content: CustomInput(controller: controller, hintText: 'edit_request.reason_hint'.tr(), minLines: 2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text('logout.cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text('edit_request.send'.tr())),
        ],
      ),
    );
    final reason = controller.text.trim();
    controller.dispose();
    if (send == true) await viewModel.onAskToEditTap(reason.isEmpty ? null : reason);
  }

  @override
  void onViewModelReady(SessionViewModel viewModel) => viewModel.init();

  @override
  SessionViewModel viewModelBuilder(BuildContext context) => SessionViewModel(sessionId);
}
