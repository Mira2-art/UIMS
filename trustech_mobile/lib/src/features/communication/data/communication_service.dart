import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/client/dio_provider.dart';
import 'mock/communication_mock.dart';
import 'mock/notification_mock.dart';

class CommunicationService {
  CommunicationService(this._dio);
  final Dio _dio;

  Future<List<Announcement>> announcements() async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.announcements);
    return (res.data ?? const []).cast<Map<String, dynamic>>().map(_announcement).toList();
  }

  Future<List<TrustechNotification>> notifications() async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.notifications);
    return (res.data ?? const []).cast<Map<String, dynamic>>().map(_notification).toList();
  }

  Future<void> markRead(String id) =>
      _dio.patch<void>(ApiEndpoints.notificationRead(id));

  Future<void> markAllRead() =>
      _dio.patch<void>('${ApiEndpoints.notifications}/read-all');

  Announcement _announcement(Map<String, dynamic> a) {
    final content = (a['content'] ?? '') as String;
    return Announcement(
      id: (a['announcement_id'] ?? '') as String,
      title: (a['title'] ?? '') as String,
      content: content,
      excerpt: content.length > 120 ? '${content.substring(0, 120)}…' : content,
      date: _date(a['published_at'] ?? a['created_at']),
      category: AnnouncementCategory.academic,
      imageUrl: null,
      isPinned: (a['is_pinned'] ?? false) as bool,
      isFeatured: (a['is_urgent'] ?? false) as bool,
      author: '—',
    );
  }

  TrustechNotification _notification(Map<String, dynamic> n) => TrustechNotification(
        id: (n['notification_id'] ?? '') as String,
        title: (n['title'] ?? '') as String,
        message: (n['message'] ?? '') as String,
        timestamp: _date(n['created_at']),
        category: _category(n['notification_type'] as String?),
        isRead: (n['is_read'] ?? false) as bool,
        actionLabel: null,
      );

  NotificationCategory _category(String? t) {
    switch (t?.toUpperCase()) {
      case 'COURSE':
      case 'ENROLLMENT':
        return NotificationCategory.courses;
      case 'GRADE':
      case 'RESULT':
        return NotificationCategory.grades;
      case 'FINANCE':
      case 'PAYMENT':
        return NotificationCategory.finance;
      default:
        return NotificationCategory.security;
    }
  }

  DateTime _date(Object? v) =>
      v == null ? DateTime.now() : (DateTime.tryParse(v.toString()) ?? DateTime.now());
}

final communicationServiceProvider =
    Provider<CommunicationService>((ref) => CommunicationService(ref.watch(dioProvider)));
