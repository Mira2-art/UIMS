import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock/finance_mock.dart';

final financeOverviewProvider = Provider((ref) {
  // TODO(backend): replace with /finance/summary
  return FinanceMock.financeOverview;
});

final chargesProvider = Provider((ref) {
  // TODO(backend): replace with /finance/charges
  return FinanceMock.charges;
});

final chargeDetailProvider = Provider.family<Charge?, String>((ref, id) {
  // TODO(backend): replace with /finance/charges/{id}
  final charges = ref.watch(chargesProvider);
  final matches = charges.where((c) => c.id == id);
  return matches.isEmpty ? null : matches.first;
});

final paymentsProvider = Provider((ref) {
  // TODO(backend): replace with /finance/payments
  return FinanceMock.payments;
});

final scholarshipsProvider = Provider((ref) {
  // TODO(backend): replace with /finance/scholarships
  return FinanceMock.scholarships;
});
