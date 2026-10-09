import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/app_card.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';
import 'package:teachers_app/ui/widgets/meta.dart';

/// Payment / Program Progress / Schedule / Students cards.
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.children, this.meta});

  final String title;
  final MetaItem? meta;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: CustomText.titleSmall(text: title)),
              if (meta != null) MetaRow([meta!]),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// "Plan ........ Flat amount per student"
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.valueColor, this.bold = false});

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.w700 : FontWeight.w400;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: CustomText.bodyMedium(text: label, fontWeight: weight)),
          CustomText.bodyMedium(text: value, textColor: valueColor, fontWeight: valueColor != null ? FontWeight.w700 : weight),
        ],
      ),
    );
  }
}

/// Done sessions (orange) over expected-by-now (peach) over total (grey).
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.done, required this.expected});

  final double done;
  final double expected;

  @override
  Widget build(BuildContext context) {
    Widget bar(double f, Color c) => FractionallySizedBox(
          widthFactor: f,
          child: Container(
            decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(AppStyles.borderRadiusTinyValue)),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 7,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          builder: (_, t, _) => Stack(
            children: [
              bar(1, AppColors.greyColorLight),
              bar(expected * t, AppColors.accentBorderColor),
              bar(done * t, AppColors.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
