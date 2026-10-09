import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/choice_toggle.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';

/// Student name, P / A toggle and the Evaluation button.
class AttendanceRow extends StatelessWidget {
  const AttendanceRow({
    super.key,
    required this.name,
    required this.selected,
    required this.evaluated,
    required this.onChanged,
    this.readOnly = false,
    required this.onEvaluationTap,
    required this.onHistoryTap,
  });

  final String name;
  final int? selected;
  final bool evaluated;
  final ValueChanged<int> onChanged;
  final bool readOnly;
  final VoidCallback onEvaluationTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final absent = selected == 1;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: CustomText.bodyLarge(text: name)),
              IconCircle(Icons.history, size: 14, onTap: onHistoryTap),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceToggle(
                  selected: selected,
                  onChanged: readOnly ? null : onChanged,
                  options: [
                    ToggleOption('session.p'.tr(), AppColors.greenColor, icon: Icons.check),
                    ToggleOption('session.a'.tr(), AppColors.redColor, icon: Icons.close),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: absent || (readOnly && !evaluated) ? null : onEvaluationTap,
                  text: 'session.evaluation'.tr(),
                  icon: evaluated ? Icons.checklist : Icons.format_list_bulleted,
                  color: evaluated ? AppColors.greenColor : AppColors.darkColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
