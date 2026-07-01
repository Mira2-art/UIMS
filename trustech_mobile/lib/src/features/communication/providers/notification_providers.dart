import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/communication_service.dart';
import '../data/mock/notification_mock.dart';

/// Loads notifications from GET /communication/notifications and keeps a local
/// mutation API (mark-as-read) that calls the backend then updates state.
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<TrustechNotification>>((ref) {
  return NotificationsNotifier(ref.watch(communicationServiceProvider))..load();
});

class NotificationsNotifier extends StateNotifier<List<TrustechNotification>> {
  NotificationsNotifier(this._service) : super(const []);

  final CommunicationService _service;

  Future<void> load() async {
    try {
      state = await _service.notifications();
    } catch (_) {
      state = const [];
    }
  }

  Future<void> markAsRead(String id) async {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    try {
      await _service.markRead(id);
    } catch (_) {/* keep optimistic local state */}
  }

  Future<void> markAllAsRead() async {
    state = [for (final n in state) n.copyWith(isRead: true)];
    try {
      await _service.markAllRead();
    } catch (_) {}
  }
}

final filteredNotificationsProvider =
    Provider.family<List<TrustechNotification>, NotificationCategory?>((ref, category) {
  final notifications = ref.watch(notificationsProvider);
  if (category == null) return notifications;
  return notifications.where((n) => n.category == category).toList();
});
