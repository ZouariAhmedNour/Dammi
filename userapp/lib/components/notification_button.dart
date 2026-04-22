import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/components/notification_badge_icon.dart';
import 'package:userapp/providers/urgent_requests_provider.dart';
import 'package:userapp/theme/app_colors.dart';

class NotificationButton extends ConsumerWidget {
  final bool isPertinent;
  final int? userId;

  const NotificationButton({
    super.key,
    required this.isPertinent,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnreadAsync =
        (isPertinent && userId != null)
            ? ref.watch(
                hasUnreadUrgentRequestsProvider(userId!),
              )
            : const AsyncValue<bool>.data(false);

    return hasUnreadAsync.when(
     data: (hasUnread) {
  final unreadCount = hasUnread ? 3 : 0;

  return NotificationBadgeIcon(
    active: isPertinent && hasUnread,
    unreadCount: unreadCount,
    onTap: isPertinent
        ? () async {
            if (userId != null) {
              await ref
                  .read(urgentSeenStorageProvider)
                  .markSeen(userId!);

              ref.invalidate(
                hasUnreadUrgentRequestsProvider(userId!),
              );
            }

            if (context.mounted) {
              context.go('/demandes-urgentes');
            }
          }
        : null,
  );
},
      loading: () => const Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primaryDark,
        size: 22,
      ),
      error: (_, __) => const Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primaryDark,
        size: 22,
      ),
    );
  }
}