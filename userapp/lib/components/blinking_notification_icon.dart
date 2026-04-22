import 'package:flutter/material.dart';
import 'package:userapp/theme/app_colors.dart';

class BlinkingNotificationIcon extends StatefulWidget {
  final bool active;
  final VoidCallback? onTap;

  const BlinkingNotificationIcon({
    super.key,
    required this.active,
    required this.onTap,
  });

  @override
  State<BlinkingNotificationIcon> createState() =>
      _BlinkingNotificationIconState();
}

class _BlinkingNotificationIconState
    extends State<BlinkingNotificationIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingNotificationIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return IconButton(
        onPressed: widget.onTap,
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.primaryDark,
          size: 22,
        ),
      );
    }

    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.35,
        end: 1,
      ).animate(_controller),
      child: IconButton(
        onPressed: widget.onTap,
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.notifications_active_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    );
  }
}