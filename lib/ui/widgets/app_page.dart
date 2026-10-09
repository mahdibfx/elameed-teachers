import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/common/app_styles.dart';
import 'package:teachers_app/ui/widgets/app_bottom_nav.dart';
import 'package:teachers_app/ui/widgets/fade_in_up.dart';
import 'package:teachers_app/ui/widgets/page_header.dart';

/// Header + scrollable body (+ optional pinned [top] and bottom nav).
/// Tab roots pass no [tabIndex]: MainView draws the nav once for them.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.children,
    this.onBack,
    this.top,
    this.tabIndex,
    this.onTabTap,
    this.onRefresh,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onBack;

  /// Non-scrolling area under the header (search + filters).
  final Widget? top;
  final int? tabIndex;
  final ValueChanged<int>? onTabTap;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    Widget list = ListView(
      padding: const EdgeInsets.fromLTRB(AppStyles.screenPadding, 4, AppStyles.screenPadding, 24),
      children: [FadeInUp(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children))],
    );
    if (onRefresh != null) list = RefreshIndicator(color: AppColors.primaryColor, onRefresh: onRefresh!, child: list);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: title, onBack: onBack),
            if (top != null)
              Padding(padding: const EdgeInsets.fromLTRB(AppStyles.screenPadding, 0, AppStyles.screenPadding, 12), child: top),
            Expanded(child: list),
          ],
        ),
      ),
      bottomNavigationBar: tabIndex == null ? null : AppBottomNav(currentIndex: tabIndex!, onTap: onTabTap ?? (_) {}),
    );
  }
}
