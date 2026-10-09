import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';

/// Past session on Group Info: date, time, attendance / unit / note.
class GroupSessionCard extends StatelessWidget {
  const GroupSessionCard({super.key, required this.session, required this.attendance, required this.onTap});

  final Session session;
  final String attendance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String label, String value, {Widget? trailing}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.secondaryColor),
              const SizedBox(width: 6),
              SizedBox(width: 80, child: CustomText.bodyMedium(text: label, textColor: AppColors.secondaryColor, fontWeight: FontWeight.w600)),
              Expanded(child: CustomText.bodyMedium(text: value.isEmpty ? '—' : value, fontWeight: FontWeight.w400)),
              ?trailing,
            ],
          ),
        );

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateLabel(session.date),
          const SizedBox(height: 12),
          CustomText(timeRange(session.start, session.end), fontSize: 18, fontWeight: FontWeight.w700),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: AppColors.borderColor)),
          row(Icons.badge_outlined, 'session.attendance'.tr(), attendance, trailing: const IconCircle(Icons.history, size: 14)),
          row(Icons.menu_book_outlined, 'session.unit'.tr(), session.unit),
          row(Icons.description_outlined, 'session.note'.tr(), session.notes),
        ],
      ),
    );
  }
}
