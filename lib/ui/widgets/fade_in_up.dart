import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FadeInUp extends HookWidget {
  const FadeInUp({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final c = useAnimationController(duration: const Duration(milliseconds: 400));
    final t = useAnimation(CurvedAnimation(parent: c, curve: Curves.easeOut));
    useEffect(() {
      Future.delayed(delay, () {
        if (context.mounted) c.forward();
      });
      return null;
    }, const []);
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
    );
  }
}
