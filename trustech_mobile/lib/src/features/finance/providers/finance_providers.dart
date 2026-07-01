import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../data/finance_service.dart';
import '../data/mock/finance_mock.dart';

String _sid(Ref ref) {
  final sid = ref.watch(studentIdProvider);
  if (sid == null) throw StateError('No active student session');
  return sid;
}

final financeOverviewProvider = FutureProvider<FinanceOverview>((ref) =>
    ref.watch(financeServiceProvider).overview(_sid(ref)));

final chargesProvider = FutureProvider<List<Charge>>((ref) =>
    ref.watch(financeServiceProvider).charges(_sid(ref)));

final chargeDetailProvider = FutureProvider.family<Charge?, String>((ref, id) async {
  final charges = await ref.watch(chargesProvider.future);
  final matches = charges.where((c) => c.id == id);
  return matches.isEmpty ? null : matches.first;
});

final paymentsProvider = FutureProvider<List<PaymentHistory>>((ref) =>
    ref.watch(financeServiceProvider).payments(_sid(ref)));

final scholarshipsProvider = FutureProvider<List<Scholarship>>((ref) =>
    ref.watch(financeServiceProvider).scholarships(_sid(ref)));
