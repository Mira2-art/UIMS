import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock/notification_mock.dart';

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<TrustechNotification>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<TrustechNotification>> {
  NotificationsNotifier() : super(NotificationMock.notifications);

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final n in state) n.copyWith(isRead: true),
    ];
  }
}

final filteredNotificationsProvider = Provider.family<List<TrustechNotification>, NotificationCategory?>((ref, category) {
  final notifications = ref.watch(notificationsProvider);
  if (category == null) return notifications;
  return notifications.where((n) => n.category == category).toList();
});
