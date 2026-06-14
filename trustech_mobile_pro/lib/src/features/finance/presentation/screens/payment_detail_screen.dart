// Roles: BURSAR (FINANCE: manage)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';
import 'package:trustech_mobile_pro/src/features/finance/providers/finance_providers.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({super.key, required this.paymentId});

  final String paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payment = ref.watch(paymentDetailProvider(paymentId));
    final cs = Theme.of(context).colorScheme;

    if (payment == null) {
      return const TrustechScaffold(
        title: 'Payment Detail',
        body: Center(child: Text('Payment not found')),
      );
    }

    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Payment Detail'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrustechCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TrustechAvatar(name: payment.studentName, radius: 40),
                  const SizedBox(height: 16),
                  Text(payment.studentName, style: TrustechTypography.h2.copyWith(color: cs.onSurface)),
                  Text('ID: ${payment.studentId}', style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('\$${payment.amount.toStringAsFixed(2)}', style: TrustechTypography.displayLarge.copyWith(color: cs.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatusChip(label: payment.status, kind: payment.status == 'Verified' ? StatusKind.success : StatusKind.error),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const SectionHeader(title: 'Transaction Details'),
            const SizedBox(height: 12),
            InfoListCard(
              children: [
                InfoListRow(title: 'Receipt Number', subtitle: payment.receiptNo, icon: Icons.receipt),
                InfoListRow(title: 'Payment Method', subtitle: payment.method, icon: Icons.credit_card),
                InfoListRow(title: 'Date Processed', subtitle: DateFormat('MMM dd, yyyy').format(payment.date), icon: Icons.calendar_today),
              ],
            ),
            const SizedBox(height: 24),
            
            if (payment.status != 'Verified')
              TrustechButton(
                label: 'Verify Payment',
                icon: Icons.check_circle,
                onPressed: () {},
              )
            else
              TrustechButton(
                label: 'Reverse Payment',
                variant: TrustechButtonVariant.destructive,
                icon: Icons.undo,
                onPressed: () {},
              ),
          ],
        ),
      ),
    );
  }
}
