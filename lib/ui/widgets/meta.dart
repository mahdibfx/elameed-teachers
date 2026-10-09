import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/models/models.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/utils/formatters.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

/// Small icon + text ("6 Students", "2 Sessions / week", "✓ 5 Present").
class MetaItem {
  const MetaItem(this.icon, this.text, {this.color});
  final IconData icon;
  final String text;
  final Color? color;
}

/// Row of [MetaItem]s separated by thin dividers.
class MetaRow extends StatelessWidget {
  const MetaRow(this.items, {super.key, this.dark = false});

  final List<MetaItem> items;

  /// White text for dark header cards.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final base = dark ? Colors.white : AppColors.textColor;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 13, color: item.color ?? base),
              const SizedBox(width: 3),
              CustomText.caption(
                text: item.text,
                textColor: item.color ?? base,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
      ],
    );
  }
}

/// "Support - English - BAC | Cycle 1"
class SubtitleTag extends StatelessWidget {
  const SubtitleTag({
    super.key,
    required this.subtitle,
    this.tag = '',
    this.dark = false,
  });

  final String subtitle;
  final String tag;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white70 : AppColors.secondaryColor;
    return Row(
      children: [
        Flexible(
          child: CustomText.bodySmall(text: subtitle, textColor: color),
        ),
        if (tag.isNotEmpty) ...[
          Container(
            width: 1,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: dark ? Colors.white38 : AppColors.accentBorderColor,
          ),
          Flexible(
            child: CustomText.bodySmall(
              text: tag,
              textColor: dark ? Colors.white : AppColors.secondaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

/// "Today  Saturday 09/19/2026"
class DateLabel extends StatelessWidget {
  const DateLabel(this.date, {super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final (key, n) = relativeDayKey(date, DateTime.now());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        CustomText.bodyLarge(text: key.tr(args: ['$n'])),
        const SizedBox(width: 8),
        Flexible(
          child: CustomText.bodySmall(
            text: fullDate(date),
            textColor: AppColors.secondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Grey circle holding an icon (clock, unit book, note).
class IconCircle extends StatelessWidget {
  const IconCircle(this.icon, {super.key, this.size = 22, this.onTap});

  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAltColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(size * .35),
          child: Icon(icon, size: size, color: AppColors.secondaryColor),
        ),
      ),
    );
  }
}

/// Clock circle + "14:00 ~ 16:00"
class TimeRange extends StatelessWidget {
  const TimeRange({super.key, required this.start, required this.end});

  final String start;
  final String end;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const IconCircle(Icons.schedule, size: 14),
        const SizedBox(width: 8),
        CustomText(
          timeRange(start, end),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}

String timeRange(String start, String end) => '$start ~ $end';

/// "6 Students | 2 Sessions / week | 4/26 Sessions"
List<MetaItem> groupMetaItems(Group g) => [
  studentsMeta(g.students.length),
  MetaItem(
    Icons.calendar_today_outlined,
    'meta.per_week'.tr(args: ['${g.sessionsPerWeek}']),
  ),
  MetaItem(
    Icons.event_note_outlined,
    'meta.progress'.tr(args: ['${g.heldSessions}', '${g.plannedSessions}']),
  ),
];

MetaItem studentsMeta(int count) =>
    MetaItem(Icons.badge_outlined, 'meta.students'.tr(args: ['$count']));

/// "Cycle 1" tag used next to the course name on session cards.
String cycleTag(int cycle) => 'meta.cycle'.tr(args: ['$cycle']);

/// "Floor 1 Room 3"
String roomLabel(Room r) => 'meta.room'.tr(args: ['${r.floor}', r.index]);
