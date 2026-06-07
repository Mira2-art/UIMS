import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock/communication_mock.dart';

final announcementsProvider = Provider((ref) {
  // TODO(backend): replace with /announcements
  return CommunicationMock.announcements;
});

final announcementDetailProvider = Provider.family<Announcement?, String>((ref, id) {
  // TODO(backend): replace with /announcements/{id}
  final announcements = ref.watch(announcementsProvider);
  final matches = announcements.where((a) => a.id == id);
  return matches.isEmpty ? null : matches.first;
});
