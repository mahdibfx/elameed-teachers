import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

// ponytail: filled only; the designs have no outlined/text buttons. Add variants when one shows up.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.color = AppColors.darkColor,
    this.isLoading = false,
    this.large = false,
  });

  /// Orange full-width "Submit ..." button at the bottom of forms.
  factory CustomButton.submit({required VoidCallback? onPressed, required String text, IconData? icon, bool isLoading = false}) =>
      CustomButton(onPressed: onPressed, text: text, icon: icon, color: AppColors.primaryColor, isLoading: isLoading, large: true);

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color color;
  final bool isLoading;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          disabledBackgroundColor: onPressed == null && !isLoading ? AppColors.greyColor : color.withValues(alpha: .7),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: large ? 14 : 10, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(large ? AppStyles.borderRadiusMediumValue : AppStyles.borderRadiusSmallValue),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: large ? 20 : 16, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: CustomText(
                        text,
                        fontSize: large ? 18 : 14,
                        fontWeight: large ? FontWeight.w700 : FontWeight.w600,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
