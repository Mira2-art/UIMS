import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../../communication/providers/communication_providers.dart';
import '../../finance/providers/finance_providers.dart';
import '../../grades/providers/grades_providers.dart';
import '../data/mock/home_mock.dart';

/// Dashboard summary composed from the already-wired feature providers:
/// standing (GPA), finance (outstanding balance), and announcements.
final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  final user = ref.watch(sessionProvider).user;
  final standing = await ref.watch(standingProvider.future);
  final overview = await ref.watch(financeOverviewProvider.future);
  final announcements = await ref.watch(announcementsProvider.future);

  return HomeSummary(
    studentName: user?.fullName ?? 'Student',
    program: '—',
    level: '—',
    gpa: standing.cgpa > 0 ? standing.cgpa : standing.currentGpa,
    standing: standing.status.label,
    outstandingBalance: overview.totalBalance,
    todaysClasses: const [], // TODO(backend): /students/{id}/timetable (today)
    announcements: announcements
        .take(5)
        .map((a) => HomeAnnouncement(
              id: a.id,
              category: a.category.label,
              title: a.title,
              excerpt: a.excerpt,
            ))
        .toList(),
  );
});
