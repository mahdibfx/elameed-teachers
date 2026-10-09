import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';

/// White card with an optional icon circle, a label and a radio dot; orange border when selected.
class OptionTile extends StatelessWidget {
  const OptionTile({super.key, required this.label, required this.selected, required this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadiusMediumValue),
          side: BorderSide(color: selected ? AppColors.primaryColor : AppColors.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: icon == null ? 16 : 12),
            child: Row(
              children: [
                if (icon != null) ...[IconCircle(icon!, size: 20), const SizedBox(width: 16)],
                Expanded(
                  child: CustomText.bodyLarge(text: label, fontWeight: FontWeight.w600),
                ),
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selected ? AppColors.primaryColor : AppColors.accentBorderColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
