import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/components/notification_badge_icon.dart';
import 'package:userapp/providers/blood_request_provider.dart';
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
    /// si non pertinent ou pas connecté → icône simple
    if (!isPertinent || userId == null) {
      return const Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primaryDark,
        size: 22,
      );
    }

    final hasUnreadAsync =
        ref.watch(hasUnreadUrgentRequestsProvider(userId!));

    final requestsAsync =
        ref.watch(compatibleUrgentRequestsProvider(userId!));

    return hasUnreadAsync.when(
      data: (hasUnread) {
        return requestsAsync.when(
          data: (requests) {
            final unreadCount = hasUnread ? requests.length : 0;

            return NotificationBadgeIcon(
              active: hasUnread,
              unreadCount: unreadCount,
              onTap: () async {
                /// marquer comme vu
                await ref
                    .read(urgentSeenStorageProvider)
                    .markSeen(userId!);

                /// refresh badge + données
                ref.invalidate(
                    hasUnreadUrgentRequestsProvider(userId!));
                ref.invalidate(
                    compatibleUrgentRequestsProvider(userId!));

                if (context.mounted) {
                  context.go('/demandes-urgentes');
                }
              },
            );
          },

          /// loading requests
          loading: () => const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primaryDark,
            size: 22,
          ),

          /// error requests
          error: (_, __) => const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primaryDark,
            size: 22,
          ),
        );
      },

      /// loading unread
      loading: () => const Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primaryDark,
        size: 22,
      ),

      /// error unread
      error: (_, __) => const Icon(
        Icons.notifications_none_rounded,
        color: AppColors.primaryDark,
        size: 22,
      ),
    );
  }
}