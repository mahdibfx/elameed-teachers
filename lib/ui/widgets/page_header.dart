import 'package:flutter/material.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/services/auth_service.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/account_sheet.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

/// Orange back arrow + title + teacher avatar (tap → language / logout sheet).
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.onBack});

  final String title;

  /// Hidden when null (tab roots).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final auth = locator<AuthService>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppStyles.screenPadding - 8, 8, AppStyles.screenPadding, 8),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor))
          else
            const SizedBox(width: 8),
          const SizedBox(width: 4),
          Expanded(child: CustomText.titleLarge(text: title)),
          GestureDetector(
            onTap: () => showAccountSheet(context),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColorLight),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryColor,
                child: CustomText(auth.currentUser?.initials ?? '', fontSize: 14, fontWeight: FontWeight.w700, textColor: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
