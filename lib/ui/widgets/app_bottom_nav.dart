import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

/// Groups / Sessions / Students / Payments. Shown on tab roots and on every pushed screen.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (Icons.folder_copy_outlined, 'nav.groups'),
    (Icons.calendar_month_outlined, 'nav.sessions'),
    (Icons.badge_outlined, 'nav.students'),
    (Icons.attach_money, 'nav.payments'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: AppColors.accentBorderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: i == currentIndex ? AppColors.primaryColorLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmallValue),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_tabs[i].$1, size: 24, color: i == currentIndex ? AppColors.primaryColor : AppColors.secondaryColor),
                          const SizedBox(height: 2),
                          CustomText(
                            _tabs[i].$2.tr(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                            textColor: i == currentIndex ? AppColors.primaryColor : AppColors.secondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
