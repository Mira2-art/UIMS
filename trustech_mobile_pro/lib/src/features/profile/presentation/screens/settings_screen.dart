import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/core/locales/locale_provider.dart';
import 'package:trustech_mobile_pro/src/core/theme/theme_provider.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

// Roles: all staff. Pushed (account).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final mode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppHeaderBar.back(
        title: 'Settings',
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          const _Label('DISPLAY & LANGUAGE'),
          const SizedBox(height: 8),
          TrustechCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode_outlined, color: cs.onSurfaceVariant),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Theme',
                                style: TrustechTypography.bodyLarge
                                    .copyWith(fontWeight: FontWeight.w600, color: cs.onSurface)),
                            Text(_themeLabel(mode),
                                style: TrustechTypography.caption
                                    .copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      _ThemeSegmented(
                        mode: mode,
                        onChanged: (m) => ref.read(themeProvider.notifier).setTheme(m),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: cs.outlineVariant),
                InfoListRow(
                  title: 'Language',
                  subtitle: locale?.languageCode == 'fr' ? 'Français' : 'English (United States)',
                  icon: Icons.language_outlined,
                  showChevron: true,
                  onTap: () => _languageSheet(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _Label('SUPPORT'),
          const SizedBox(height: 8),
          InfoListCard(
            children: [
              InfoListRow(
                title: 'Help & Support',
                icon: Icons.help_outline,
                trailing: Icon(Icons.open_in_new, size: 18, color: cs.outline),
                onTap: () {},
              ),
              InfoListRow(
                title: 'About',
                subtitle: 'Trustech Staff Pro v2.10.4',
                icon: Icons.info_outline,
                trailing: const StatusChip(label: 'Latest', kind: StatusKind.warning),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Manage your active session and academic data synchronization.',
                  textAlign: TextAlign.center,
                  style: TrustechTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                TrustechButton(
                  label: 'Sign out',
                  icon: Icons.logout,
                  variant: TrustechButtonVariant.destructive,
                  onPressed: () {
                    // TODO(backend): POST /auth/logout + clear session.
                    context.go('/welcome');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text('© 2026 Trustech Educational Systems',
                style: TrustechTypography.caption.copyWith(color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.system => 'System default',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  void _languageSheet(BuildContext context, WidgetRef ref) {
    showAppSheet<void>(context, (_) {
      final current = ref.read(localeProvider);
      return SheetScaffold(
        title: 'Language',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedSelectorRow(
              label: 'English (United States)',
              leadingIcon: Icons.language,
              selected: current?.languageCode != 'fr',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(AppLocales.en);
                Navigator.of(context).pop();
              },
            ),
            SegmentedSelectorRow(
              label: 'Français',
              leadingIcon: Icons.translate,
              selected: current?.languageCode == 'fr',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(AppLocales.fr);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TrustechTypography.overline
            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
}

class _ThemeSegmented extends StatelessWidget {
  const _ThemeSegmented({required this.mode, required this.onChanged});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const options = [
      (ThemeMode.system, 'System'),
      (ThemeMode.light, 'Light'),
      (ThemeMode.dark, 'Dark'),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (m, label) in options)
            GestureDetector(
              onTap: () => onChanged(m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: m == mode ? cs.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TrustechTypography.caption.copyWith(
                    color: m == mode ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: m == mode ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
