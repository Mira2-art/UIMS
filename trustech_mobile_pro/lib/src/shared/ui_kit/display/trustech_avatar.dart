import 'package:flutter/material.dart';

/// Circular avatar that renders a network image when available and otherwise
/// falls back to the user's initials on a brand-tinted background.
class TrustechAvatar extends StatelessWidget {
  const TrustechAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 22,
  });

  final String? imageUrl;
  final String? name;
  final double radius;

  String get _initials {
    final parts = (name ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: cs.primary.withValues(alpha: 0.12),
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: cs.primary.withValues(alpha: 0.12),
      child: Text(
        _initials,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
