import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';
import '../../utils/theme_helper.dart';

/// One destination in [AppBottomNav].
class AppNavItem {
  const AppNavItem({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Custom 5-tab bottom navigation matching the design (filled active icon +
/// teal label, hairline top border, safe-area aware). Drive it from a
/// `StatefulShellRoute` (currentIndex + onTap → goBranch).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = studentNavItems,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  /// Default student destinations: Home · Courses · Grades · Finance · Profile.
  static const List<AppNavItem> studentNavItems = [
    AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    AppNavItem(icon: Icons.school_outlined, activeIcon: Icons.school, label: 'Courses'),
    AppNavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Grades'),
    AppNavItem(icon: Icons.payments_outlined, activeIcon: Icons.payments, label: 'Finance'),
    AppNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: context.cBackground,
        border: Border(top: BorderSide(color: context.cBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(12),
                    child: _Item(item: items[i], selected: i == currentIndex, color: cs),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.selected, required this.color});
  final AppNavItem item;
  final bool selected;
  final ColorScheme color;

  @override
  Widget build(BuildContext context) {
    final c = selected ? color.primary : color.onSurfaceVariant;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(selected ? item.activeIcon : item.icon, color: c, size: 24),
        const SizedBox(height: 4),
        Text(
          item.label,
          style: TrustechTypography.caption.copyWith(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: c),
        ),
      ],
    );
  }
}
