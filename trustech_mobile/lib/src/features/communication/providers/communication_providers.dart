import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/communication_service.dart';
import '../data/mock/communication_mock.dart';

/// GET /communication/announcements.
final announcementsProvider = FutureProvider<List<Announcement>>((ref) =>
    ref.watch(communicationServiceProvider).announcements());

/// Detail derived from the list (no per-id leak needed).
final announcementDetailProvider =
    FutureProvider.family<Announcement?, String>((ref, id) async {
  final list = await ref.watch(announcementsProvider.future);
  final matches = list.where((a) => a.id == id);
  return matches.isEmpty ? null : matches.first;
});
