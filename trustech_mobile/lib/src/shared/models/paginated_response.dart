/// Generic wrapper for list endpoints.
///
/// The backend currently returns bare JSON arrays for list routes, so
/// [PaginatedResponse.fromList] wraps a decoded list with client-side paging
/// metadata. If/when the backend adds envelope pagination, add a matching
/// `fromJson` factory here without touching call sites.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    this.total,
    this.limit,
    this.offset,
  });

  final List<T> items;
  final int? total;
  final int? limit;
  final int? offset;

  bool get isEmpty => items.isEmpty;

  factory PaginatedResponse.fromList(
    List<dynamic> data,
    T Function(Map<String, dynamic>) fromJson, {
    int? limit,
    int? offset,
  }) {
    return PaginatedResponse<T>(
      items: data
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false),
      total: data.length,
      limit: limit,
      offset: offset,
    );
  }
}
