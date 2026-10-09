import 'package:flutter/material.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';

/// Groups list ("View Group") and student history ("View Attendance").
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.subtitle,
    required this.tag,
    required this.buttonText,
    required this.buttonIcon,
    required this.onTap,
    this.period,
  });

  final Group group;

  final String subtitle;

  /// Empty on the groups list, teacher name on the student history.
  final String tag;
  final String buttonText;
  final IconData buttonIcon;
  final VoidCallback onTap;

  /// "09/19/2026 ~ ongoing"
  final String? period;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.titleSmall(text: group.name),
          const SizedBox(height: 4),
          SubtitleTag(subtitle: subtitle, tag: tag),
          const SizedBox(height: 4),
          MetaRow(groupMetaItems(group)),
          if (period != null) ...[
            const SizedBox(height: 14),
            CustomText.bodyMedium(text: period!, fontWeight: FontWeight.w600),
          ],
          const SizedBox(height: 14),
          CustomButton(onPressed: onTap, text: buttonText, icon: buttonIcon),
        ],
      ),
    );
  }
}
