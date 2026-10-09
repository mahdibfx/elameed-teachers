import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';

/// Search fields, date pickers, leaving time and the note area.
class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.minLines,
    this.filled = false,
    this.borderRadius,
    this.keyboardType,
    this.obscureText = false,
  });

  /// Grey "Search by ..." field with the orange-tinted border.
  factory CustomInput.search({required TextEditingController controller, required String hintText, ValueChanged<String>? onChanged}) =>
      CustomInput(controller: controller, hintText: hintText, prefixIcon: Icons.search, onChanged: onChanged, filled: true);

  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? minLines;
  final bool filled;
  final BorderRadius? borderRadius;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(AppStyles.borderRadiusMediumValue),
      borderSide: const BorderSide(color: AppColors.accentBorderColor),
    );
    Widget field = TextField(
      controller: controller,
      onChanged: onChanged,
      readOnly: readOnly || onTap != null,
      minLines: minLines,
      maxLines: minLines == null ? 1 : minLines! + 2,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14, color: AppColors.textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.mutedColor, fontSize: 14),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: AppColors.secondaryColor),
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon, size: 20, color: AppColors.textColor),
        filled: true,
        fillColor: filled ? AppColors.surfaceAltColor : AppColors.surfaceColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.primaryColor)),
      ),
    );

    // Picker trigger: make the whole field tappable.
    if (onTap != null) {
      field = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AbsorbPointer(child: field),
      );
    }
    return field;
  }
}
