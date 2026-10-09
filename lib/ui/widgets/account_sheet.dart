import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:teachers_app/app/app.locator.dart';
import 'package:teachers_app/app/app.router.dart';
import 'package:teachers_app/services/auth_service.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

/// Avatar menu: language picker + logout.
// ponytail: no design for this — plain bottom sheet built from the app's components.
Future<void> showAccountSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.borderRadiusLargeValue)),
      ),
      builder: (_) => const _AccountSheet(),
    );

class _AccountSheet extends StatelessWidget {
  const _AccountSheet();

  // Each language is labelled in its own script so it's findable whatever the current language.
  static const _languages = [(Locale('en'), 'English'), (Locale('fr'), 'Français'), (Locale('ar'), 'العربية')];

  @override
  Widget build(BuildContext context) {
    final auth = locator<AuthService>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppStyles.screenPadding, 20, AppStyles.screenPadding, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText.titleSmall(text: auth.currentUser?.name ?? ''),
            if (auth.currentUser?.email.isNotEmpty ?? false) CustomText.bodySmall(text: auth.currentUser!.email),
            const SizedBox(height: 20),
            CustomText.bodyMedium(text: 'account.language'.tr(), textColor: AppColors.secondaryColor),
            const SizedBox(height: 8),
            for (final (locale, label) in _languages)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: CustomText.bodyLarge(text: label, fontWeight: FontWeight.w500),
                trailing: context.locale == locale ? const Icon(Icons.check_circle, color: AppColors.primaryColor) : null,
                onTap: () async {
                  if (context.locale == locale) return Navigator.pop(context);
                  await context.setLocale(locale);
                  // Rebuild every screen in the new language (and direction, for Arabic).
                  locator<NavigationService>().clearStackAndShow(Routes.mainView);
                },
              ),
            const Divider(color: AppColors.borderColor),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: AppColors.redColor),
              title: CustomText.bodyLarge(text: 'logout.confirm'.tr(), textColor: AppColors.redColor, fontWeight: FontWeight.w500),
              onTap: () {
                Navigator.pop(context);
                auth.confirmLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
