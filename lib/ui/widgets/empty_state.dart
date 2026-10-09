import 'package:flutter/material.dart';
import 'package:teachers_app/ui/common/app_colors.dart';
import 'package:teachers_app/ui/widgets/custom_text.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.mutedColor),
            const SizedBox(height: 12),
            CustomText.bodySmall(text: message, textAlign: TextAlign.center, maxLines: 3),
          ],
        ),
      ),
    );
  }
}

/// Loading → empty → content, animated.
class AsyncBody extends StatelessWidget {
  const AsyncBody({super.key, required this.isBusy, required this.isEmpty, required this.emptyMessage, required this.child});

  final bool isBusy;
  final bool isEmpty;
  final String emptyMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isBusy
          ? const Center(key: ValueKey('busy'), child: CircularProgressIndicator(color: AppColors.primaryColor))
          : isEmpty
              ? EmptyState(key: ValueKey('empty$emptyMessage'), message: emptyMessage)
              : child,
    );
  }
}
