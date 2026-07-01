import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/client/dio_provider.dart';
import 'mock/finance_mock.dart';

class FinanceService {
  FinanceService(this._dio);
  final Dio _dio;

  Future<List<Charge>> charges(String studentId) async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.studentCharges(studentId));
    return (res.data ?? const []).cast<Map<String, dynamic>>().map(_charge).toList();
  }

  Future<List<PaymentHistory>> payments(String studentId) async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.studentPayments(studentId));
    return (res.data ?? const []).cast<Map<String, dynamic>>().map(_payment).toList();
  }

  Future<List<Scholarship>> scholarships(String studentId) async {
    final res = await _dio.get<List<dynamic>>(ApiEndpoints.studentScholarships(studentId));
    return (res.data ?? const []).cast<Map<String, dynamic>>().map(_scholarship).toList();
  }

  /// No dedicated summary endpoint — derive it from the charges.
  Future<FinanceOverview> overview(String studentId) async {
    final all = await charges(studentId);
    final unpaid = all.where((c) => c.balance > 0).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final totalBalance = all.fold<double>(0, (s, c) => s + c.balance);
    final next = unpaid.isEmpty ? null : unpaid.first;
    return FinanceOverview(
      totalBalance: totalBalance,
      nextDueDate: next?.dueDate ?? DateTime.now(),
      nextDueAmount: next?.balance ?? 0,
      recentCharges: all.take(4).toList(),
    );
  }

  Charge _charge(Map<String, dynamic> c) {
    final amount = _d(c['amount']);
    final paid = _d(c['amount_paid']);
    final discount = _d(c['discount_amount']);
    final desc = (c['description'] as String?) ?? 'Charge';
    final parts = desc.split(' — ');
    return Charge(
      id: (c['charge_id'] ?? '') as String,
      title: parts.first,
      category: parts.length > 1 ? parts[1] : '',
      amount: amount,
      balance: (amount - paid - discount).clamp(0, double.infinity).toDouble(),
      status: _status(c['status'] as String?),
      dueDate: _date(c['due_date']),
      semester: parts.length > 1 ? parts[1] : '',
      description: desc,
    );
  }

  PaymentHistory _payment(Map<String, dynamic> p) => PaymentHistory(
        id: (p['payment_id'] ?? '') as String,
        date: _date(p['payment_date']),
        amount: _d(p['amount']),
        method: ((p['payment_method'] ?? 'CASH') as String).replaceAll('_', ' '),
        receiptNo: (p['receipt_number'] as String?) ?? '—',
        isReversed: (p['is_reversed'] ?? false) as bool,
      );

  Scholarship _scholarship(Map<String, dynamic> s) => Scholarship(
        id: (s['award_id'] ?? '') as String,
        name: (s['name'] as String?) ?? 'Scholarship Award',
        amount: _d(s['amount']),
        semester: (s['academic_year'] as String?) ?? '',
        status: (s['status'] as String?) ?? 'ACTIVE',
      );

  ChargeStatus _status(String? s) {
    switch (s) {
      case 'PAID':
        return ChargeStatus.paid;
      case 'PARTIAL':
        return ChargeStatus.partial;
      case 'WAIVED':
        return ChargeStatus.waived;
      default:
        return ChargeStatus.outstanding;
    }
  }

  double _d(Object? v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0);

  DateTime _date(Object? v) =>
      v == null ? DateTime.now() : (DateTime.tryParse(v.toString()) ?? DateTime.now());
}

final financeServiceProvider =
    Provider<FinanceService>((ref) => FinanceService(ref.watch(dioProvider)));
