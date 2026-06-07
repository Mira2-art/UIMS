import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../../../shared/providers/app_providers.dart';

class ThemeSelectionSheet extends ConsumerWidget {
  const ThemeSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);

    return SheetScaffold(
      title: 'Theme',
      child: Column(
        children: [
          _OptionRow(
            title: 'System default',
            subtitle: 'Sync with device settings',
            icon: Icons.monitor,
            isSelected: current == ThemeMode.system,
            onTap: () {
              ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _OptionRow(
            title: 'Light',
            subtitle: 'Classic academic clarity',
            icon: Icons.light_mode,
            isSelected: current == ThemeMode.light,
            onTap: () {
              ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _OptionRow(
            title: 'Dark',
            subtitle: 'Comfortable late-night study',
            icon: Icons.dark_mode,
            isSelected: current == ThemeMode.dark,
            onTap: () {
              ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary.withValues(alpha: 0.2) : cs.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? cs.primaryContainer : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? cs.primary.withValues(alpha: 0.7) : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.primary, width: 2),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary,
                  ),
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
