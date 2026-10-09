import 'package:flutter/material.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';
import 'package:teachers_app/utils/formatters.dart';

/// White header of the Session and Evaluation screens.
class SessionHeaderCard extends StatelessWidget {
  const SessionHeaderCard({
    super.key,
    required this.session,
    this.fields = const [],
    this.actions,
    this.studentName,
    this.onHistoryTap,
  });

  final Session session;

  /// Unit / Note rows under the divider.
  final List<Widget> fields;

  /// Buttons above the divider (Signal Problem, Change Classroom).
  final List<Widget>? actions;

  /// Evaluation screen: student name on top and a plain date instead of "Today …".
  final String? studentName;
  final VoidCallback? onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      decorated: true,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (studentName != null) ...[
            CustomText.bodyLarge(text: studentName!),
            const SizedBox(height: 12),
            CustomText.caption(text: fullDate(session.date), fontWeight: FontWeight.w600),
          ] else
            DateLabel(session.date),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: CustomText.headline(text: timeRange(session.start, session.end))),
              IconCircle(Icons.history, onTap: onHistoryTap),
            ],
          ),
          const SizedBox(height: 8),
          CustomText(session.groupName, fontSize: 16),
          SubtitleTag(subtitle: session.courseName, tag: cycleTag(session.cycle)),
          if (studentName == null) ...[
            const SizedBox(height: 4),
            MetaRow([
              studentsMeta(session.studentsCount),
              if (session.room != null) MetaItem(Icons.meeting_room_outlined, roomLabel(session.room!)),
            ]),
          ],
          ...?actions,
          if (fields.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: AppColors.borderColor)),
            ...fields,
          ],
        ],
      ),
    );
  }
}

/// Icon circle + small label + value (or an inline input).
class IconField extends StatelessWidget {
  const IconField({super.key, required this.icon, required this.label, required this.child});

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          IconCircle(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.caption(text: label, textColor: AppColors.secondaryColor, fontWeight: FontWeight.w600),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Borderless input living inside an [IconField].
class InlineInput extends StatelessWidget {
  const InlineInput({super.key, required this.controller, required this.hintText, this.readOnly = false});

  final TextEditingController controller;
  final String hintText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 16, color: AppColors.textColor),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.only(top: 2),
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, color: AppColors.mutedColor),
      ),
    );
  }
}
