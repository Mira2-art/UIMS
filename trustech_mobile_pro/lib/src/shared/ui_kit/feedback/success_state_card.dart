import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Centered success panel — filled check, title, optional subtitle, and a
/// full-width CTA. Use for completed flows (e.g. "Payment Complete").
class SuccessStateCard extends StatelessWidget {
  const SuccessStateCard({
    super.key,
    required this.title,
    this.subtitle,
    this.ctaLabel,
    this.onCta,
  });

  final String title;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    const green = TrustechColors.success;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: green, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TrustechTypography.h2.copyWith(color: green),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TrustechTypography.bodySmall.copyWith(color: green.withValues(alpha: 0.9)),
            ),
          ],
          if (ctaLabel != null && onCta != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: onCta,
                style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
                child: Text(ctaLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
