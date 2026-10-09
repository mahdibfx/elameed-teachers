import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

/// White rounded card with the faint border + soft shadow used everywhere.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.decorated = false});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  /// Peach circle peeking in the top-right corner (session header cards).
  final bool decorated;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppStyles.borderRadiusLargeValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: radius,
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [BoxShadow(color: AppColors.secondaryColor.withValues(alpha: .06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                if (decorated)
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(color: AppColors.primaryColorLight.withValues(alpha: .6), shape: BoxShape.circle),
                    ),
                  ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Black header card on Group Info, Student Info, Student Attendance, Session Evaluation.
class DarkHeaderCard extends StatelessWidget {
  const DarkHeaderCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkColor,
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusLargeValue),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

/// "Running", "Today", "Attendance" … headers between cards.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: CustomText.bodyLarge(text: text)),
          ?trailing,
        ],
      ),
    );
  }
}
