import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/custom_button.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';
import 'package:teachers_app/ui/widgets/status_pill.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, required this.onTap, this.onCancel});

  final Session session;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final status = session.state;
    final marked = session.attendanceCount > 0;
    return AppCard(
      onTap: status == SessionStatus.notHeld ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TimeRange(start: session.start, end: session.end),
              ),
              session.isUpcoming ? StatusPill.upcoming(session) : StatusPill.session(status),
            ],
          ),
          const SizedBox(height: 8),
          CustomText(session.groupName, fontSize: 16),
          SubtitleTag(subtitle: session.courseName, tag: cycleTag(session.cycle)),
          const SizedBox(height: 4),
          MetaRow([
            studentsMeta(session.studentsCount),
            if (session.room != null) MetaItem(Icons.meeting_room_outlined, roomLabel(session.room!)),
            if (marked) ...[
              MetaItem(Icons.check, 'meta.present'.tr(args: ['${session.presentCount}']), color: AppColors.greenColor),
              MetaItem(Icons.close, 'meta.absent'.tr(args: ['${session.absentCount}']), color: AppColors.redColor),
            ],
          ]),
          if (status != SessionStatus.notHeld) ...[
            const SizedBox(height: 14),
            // Pending = the teacher can still mark it; held = closed by the office, view only.
            session.canCancel && onCancel != null
                ? CustomButton(onPressed: onCancel, text: 'sessions.cancel'.tr(), icon: Icons.delete_outline, color: AppColors.redColor)
                : session.isEditable
                ? CustomButton(onPressed: onTap, text: 'sessions.mark'.tr(), icon: Icons.badge_outlined, color: AppColors.primaryColor)
                : CustomButton(onPressed: onTap, text: 'sessions.view'.tr(), icon: Icons.badge_outlined),
          ],
        ],
      ),
    );
  }
}
