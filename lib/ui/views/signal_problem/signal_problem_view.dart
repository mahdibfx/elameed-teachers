import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/app_page.dart';
import 'package:teachers_app/ui/widgets/attachment_field.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_input.dart';
import 'package:teachers_app/ui/widgets/option_tile.dart';
import 'package:teachers_app/ui/widgets/session_header_card.dart';

import 'signal_problem_viewmodel.dart';

class SignalProblemView extends StackedView<SignalProblemViewModel> {
  const SignalProblemView({super.key, required this.session});

  final Session session;

  @override
  Widget builder(BuildContext context, SignalProblemViewModel viewModel, Widget? child) {
    return AppPage(
      title: 'problem.title'.tr(),
      onBack: viewModel.onBack,
      tabIndex: 1,
      onTabTap: viewModel.onTabTap,
      children: [
        SessionHeaderCard(session: session),
        SectionTitle('problem.problem'.tr()),
        for (final p in SignalProblemViewModel.problems)
          OptionTile(label: 'problem.$p'.tr(), selected: viewModel.problem == p, onTap: () => viewModel.onProblemTap(p)),
        const SizedBox(height: 4),
        SectionTitle('session.note'.tr()),
        CustomInput(controller: viewModel.noteController, hintText: 'cancel.note_hint'.tr(), minLines: 3),
        const SizedBox(height: 20),
        SectionTitle('problem.attachment'.tr()),
        AttachmentField(
          path: viewModel.imagePath,
          onPick: viewModel.onImagePicked,
          onRemove: viewModel.onRemoveImage,
        ),
        const SizedBox(height: 20),
        CustomButton.submit(
          onPressed: viewModel.onSubmit,
          text: 'problem.submit'.tr(),
          icon: Icons.flag_outlined,
          isLoading: viewModel.isSaving,
        ),
      ],
    );
  }

  @override
  SignalProblemViewModel viewModelBuilder(BuildContext context) => SignalProblemViewModel(session);
}
