import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Inline error panel with an icon, message, and a retry affordance.
/// Use for failed loads (e.g. "Connection Failed — Retry").
class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TrustechColors.destructive.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TrustechColors.destructive.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: TrustechColors.destructive),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TrustechTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: TrustechColors.destructive,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onRetry,
                    child: Text(
                      retryLabel,
                      style: TrustechTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
