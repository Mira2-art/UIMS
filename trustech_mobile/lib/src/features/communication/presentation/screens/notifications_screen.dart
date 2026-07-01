import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../providers/notification_providers.dart';
import '../../data/mock/notification_mock.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(filteredNotificationsProvider(_selectedCategory));
    final notifier = ref.read(notificationsProvider.notifier);

    // Grouping by "Today" vs "Yesterday" (Mocking the logic based on timestamp)
    final now = DateTime.now();
    final today = notifications.where((n) => n.timestamp.day == now.day).toList();
    final yesterday = notifications.where((n) => n.timestamp.day != now.day).toList();

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => notifier.markAllAsRead(),
            tooltip: 'Mark all as read',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: TrustechAvatar(radius: 16),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyNotifications()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _selectedCategory == null,
                          onSelected: () => setState(() => _selectedCategory = null),
                        ),
                        const SizedBox(width: 8),
                        ...NotificationCategory.values.map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(
                                label: cat.label,
                                isSelected: _selectedCategory == cat,
                                onSelected: () => setState(() => _selectedCategory = cat),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (today.isNotEmpty) ...[
                    _GroupHeader(
                      title: 'Today',
                      onMarkAllRead: () {
                        // TODO: Implement group-level mark as read if needed
                      },
                    ),
                    const SizedBox(height: 12),
                    ...today.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NotificationCard(
                            notification: n,
                            onTap: () => notifier.markAsRead(n.id),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  if (yesterday.isNotEmpty) ...[
                    const _GroupHeader(title: 'Yesterday'),
                    const SizedBox(height: 12),
                    ...yesterday.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NotificationCard(
                            notification: n,
                            onTap: () => notifier.markAsRead(n.id),
                          ),
                        )),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, this.onMarkAllRead});
  final String title;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        if (onMarkAllRead != null)
          TextButton(
            onPressed: onMarkAllRead,
            child: const Text('Mark all as read'),
          ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});
  final TrustechNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(notification.category, cs).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(notification.category),
              color: _getCategoryColor(notification.category, cs),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    Text(
                      _getTimeAgo(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (notification.actionLabel != null) ...[
                  const SizedBox(height: 12),
                  TrustechButton(
                    label: notification.actionLabel!,
                    variant: TrustechButtonVariant.outline,
                    onPressed: () {},
                  ),
                ],
              ],
            ),
          ),
          if (!notification.isRead) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(NotificationCategory category, ColorScheme cs) {
    switch (category) {
      case NotificationCategory.courses:
        return cs.primary;
      case NotificationCategory.grades:
        return cs.secondary;
      case NotificationCategory.finance:
        return cs.tertiary;
      case NotificationCategory.security:
        return cs.onSurfaceVariant;
    }
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.courses:
        return Icons.school;
      case NotificationCategory.grades:
        return Icons.grading;
      case NotificationCategory.finance:
        return Icons.payments;
      case NotificationCategory.security:
        return Icons.person;
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}h';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_paused_outlined, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no older notifications. Check back later for academic updates and grade releases.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
