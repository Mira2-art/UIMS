import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock/finance_mock.dart';

final feeStructuresProvider = Provider<List<FeeStructure>>((ref) {
  // TODO(backend): replace with /finance/fee-structures
  return FinanceMock.feeStructures;
});

final chargesProvider = Provider<List<Charge>>((ref) {
  // TODO(backend): replace with /finance/charges
  return FinanceMock.charges;
});

final chargeDetailProvider = Provider.family<Charge?, String>((ref, id) {
  final all = ref.watch(chargesProvider);
  final matches = all.where((c) => c.id == id);
  return matches.isEmpty ? null : matches.first;
});

final paymentsProvider = Provider<List<Payment>>((ref) {
  // TODO(backend): replace with /finance/payments
  return FinanceMock.payments;
});

final paymentDetailProvider = Provider.family<Payment?, String>((ref, id) {
  final all = ref.watch(paymentsProvider);
  final matches = all.where((p) => p.id == id);
  return matches.isEmpty ? null : matches.first;
});

final scholarshipsProvider = Provider<List<Scholarship>>((ref) {
  // TODO(backend): replace with /finance/scholarships
  return FinanceMock.scholarships;
});
