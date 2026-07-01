import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/client/dio_provider.dart';
import 'mock/timetable_mock.dart';

const _days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];

class TimetableService {
  TimetableService(this._dio);
  final Dio _dio;

  /// GET /students/{id}/timetable → group flat entries into a weekly view.
  Future<TimetableWeek> week(String studentId) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.studentTimetable(studentId),
    );
    final entries = (res.data ?? const []).cast<Map<String, dynamic>>();
    final todayIdx = DateTime.now().weekday - 1; // Mon=0

    final days = <TimetableDay>[];
    for (var i = 0; i < _days.length; i++) {
      final dayKey = _days[i];
      final dayEntries = entries
          .where((e) => (e['day_of_week'] as String?)?.toUpperCase() == dayKey)
          .map((e) => TimetableEntry(
                id: (e['entry_id'] ?? '') as String,
                courseId: (e['course_id'] ?? '') as String,
                courseCode: '—',
                courseTitle: (e['entry_type'] ?? 'Class') as String,
                timeRange: '${e['start_time'] ?? ''} - ${e['end_time'] ?? ''}',
                startTime: (e['start_time'] ?? '') as String,
                venue: (e['venue'] ?? '') as String,
                lecturer: '—',
                type: (e['entry_type'] ?? '') as String,
                isNow: false,
              ))
          .toList();
      days.add(TimetableDay(
        id: dayKey.toLowerCase(),
        label: dayKey[0] + dayKey.substring(1).toLowerCase(),
        dateLabel: '',
        isToday: i == todayIdx,
        entries: dayEntries,
      ));
    }

    return TimetableWeek(
      weekLabel: 'This Week',
      activeDayId: days[todayIdx.clamp(0, days.length - 1)].id,
      days: days,
    );
  }
}

final timetableServiceProvider =
    Provider<TimetableService>((ref) => TimetableService(ref.watch(dioProvider)));
