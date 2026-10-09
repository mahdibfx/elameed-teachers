import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

/// White card with a title ("Understanding", "Homework & next step" …).
class EvaluationSection extends StatelessWidget {
  const EvaluationSection({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText.titleSmall(text: title),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

/// Small grey label inside a section ("Arrival", "Concentration").
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: CustomText(text, fontSize: 13, maxLines: 2),
      );
}

/// Discrete scale: thin line, a dot per step, colored labels; the picked dot grows.
class StepScale extends StatelessWidget {
  const StepScale({super.key, required this.options, required this.selected, this.onChanged});

  final List<(String label, Color color)> options;
  final int selected;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final inset = constraints.maxWidth / (options.length * 2);
          return Stack(
            children: [
              Positioned(
                left: inset,
                right: inset,
                top: 9,
                child: Container(height: 1.5, color: AppColors.borderColor),
              ),
              Row(
                children: [
                  for (var i = 0; i < options.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onChanged == null ? null : () => onChanged!(i),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutBack,
                                  width: i == selected ? 14 : 4,
                                  height: i == selected ? 14 : 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == selected ? options[i].$2 : AppColors.mutedColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            CustomText(options[i].$1, fontSize: 13, textColor: options[i].$2, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Wrap of small outlined chips; selected ones fill blue.
class SelectChips extends StatelessWidget {
  const SelectChips({super.key, required this.labels, required this.isSelected, this.onTap});

  final List<String> labels;
  final bool Function(int) isSelected;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: onTap == null ? null : () => onTap!(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected(i) ? AppColors.blueColor : AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(AppStyles.borderRadiusTinyValue),
                  border: Border.all(color: isSelected(i) ? AppColors.blueColor : AppColors.borderColor),
                ),
                child: CustomText(labels[i], fontSize: 13, textColor: isSelected(i) ? Colors.white : AppColors.mutedColor),
              ),
            ),
        ],
      ),
    );
  }
}
