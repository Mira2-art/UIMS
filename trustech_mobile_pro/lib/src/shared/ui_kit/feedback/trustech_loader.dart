import 'package:flutter/material.dart';

/// Centered progress indicator for inline/full-region loading states.
class TrustechLoader extends StatelessWidget {
  const TrustechLoader({super.key, this.message, this.size = 28});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(strokeWidth: 2.6, color: cs.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen blocking overlay (e.g. during a submit). Place inside a [Stack].
class TrustechLoaderOverlay extends StatelessWidget {
  const TrustechLoaderOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: TrustechLoader(message: message),
      ),
    );
  }
}
