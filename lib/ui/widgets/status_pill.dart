import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, required this.background, this.icon});

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  factory StatusPill.session(SessionStatus status) => switch (status) {
        SessionStatus.pending => StatusPill(label: 'status.pending'.tr(), icon: Icons.more_horiz, color: AppColors.blueColor, background: AppColors.blueColorLight),
        SessionStatus.held => StatusPill(label: 'status.held'.tr(), icon: Icons.check, color: AppColors.greenColor, background: AppColors.greenColorLight),
        SessionStatus.notHeld => StatusPill(label: 'status.not_held'.tr(), icon: Icons.block, color: AppColors.redColor, background: AppColors.redColorLight),
      };

  /// Upcoming tab: confirmed / running now / still to come.
  factory StatusPill.upcoming(Session s) => s.teacherConfirmed
      ? StatusPill(label: 'status.confirmed'.tr(), icon: Icons.check, color: AppColors.greenColor, background: AppColors.greenColorLight)
      : s.hasStarted
          ? StatusPill(label: 'status.in_progress'.tr(), icon: Icons.play_arrow, color: AppColors.primaryColor, background: AppColors.primaryColorLight)
          : StatusPill(label: 'status.upcoming'.tr(), icon: Icons.hourglass_empty, color: AppColors.secondaryColor, background: AppColors.greyColorLight);

  factory StatusPill.attendance(bool present) => present
      ? StatusPill(label: 'status.present'.tr(), icon: Icons.check, color: AppColors.greenColor, background: AppColors.greenColorLight)
      : StatusPill(label: 'status.absent'.tr(), icon: Icons.close, color: AppColors.redColor, background: AppColors.redColorLight);

  factory StatusPill.running() => StatusPill(label: 'status.running'.tr(), color: AppColors.blueColor, background: AppColors.blueColorLight);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusPillValue),
        border: Border.all(color: color.withValues(alpha: .15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          CustomText(label, fontSize: 13, fontWeight: FontWeight.w600, textColor: color),
        ],
      ),
    );
  }
}
