import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

class ToggleOption {
  const ToggleOption(this.label, this.color, {this.icon});
  final String label;
  final Color color;
  final IconData? icon;
}

/// Joined two-way toggle: P / A, On time / Late, Normal / Left early.
/// Selected half fills with its color; the other shows its color as text.
class ChoiceToggle extends StatelessWidget {
  const ChoiceToggle({super.key, required this.options, required this.selected, this.onChanged});

  final List<ToggleOption> options;

  /// null = nothing picked yet.
  final int? selected;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final r = AppStyles.borderRadiusSmallValue;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onChanged == null ? null : () => onChanged!(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: i == selected ? options[i].color : AppColors.surfaceColor,
                      border: i > 0 ? const BorderDirectional(start: BorderSide(color: AppColors.borderColor)) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (options[i].icon != null) ...[
                          Icon(options[i].icon, size: 16, color: i == selected ? Colors.white : options[i].color),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: CustomText.bodyMedium(
                            text: options[i].label,
                            fontWeight: FontWeight.w600,
                            textColor: i == selected ? Colors.white : options[i].color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
