import 'package:flutter/material.dart';
import 'package:userapp/theme/app_colors.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final bool active;
  final int unreadCount;
  final VoidCallback? onTap;

  const NotificationBadgeIcon({
    super.key,
    required this.active,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = unreadCount > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            active
                ? Icons.notifications_active_rounded
                : Icons.notifications_none_rounded,
            color: active
                ? AppColors.primary
                : AppColors.primaryDark,
            size: 24,
          ),
        ),

        if (showBadge)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Text(
                unreadCount > 99
                    ? '99+'
                    : unreadCount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}