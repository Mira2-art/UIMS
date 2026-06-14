import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../../../shared/providers/app_providers.dart';
import '../widgets/language_selection_sheet.dart';
import '../widgets/theme_selection_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppHeaderBar.back(
        title: 'Settings',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: TrustechAvatar(radius: 16),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: 'APPEARANCE'),
            const SizedBox(height: 8),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Theme',
                  subtitle: _getThemeLabel(themeMode),
                  icon: Icons.palette_outlined,
                  showChevron: true,
                  onTap: () => _showThemeSheet(context, ref),
                ),
                InfoListRow(
                  title: 'Font size',
                  subtitle: 'Standard (16px)',
                  icon: Icons.text_fields_outlined,
                  showChevron: true,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionTitle(title: 'NOTIFICATIONS'),
            const SizedBox(height: 8),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Push notifications',
                  icon: Icons.notifications_active_outlined,
                  trailing: Switch.adaptive(
                    value: true,
                    activeTrackColor: cs.primary,
                    onChanged: (v) {},
                  ),
                ),
                InfoListRow(
                  title: 'Email notifications',
                  icon: Icons.mail_outline,
                  trailing: Switch.adaptive(
                    value: true,
                    activeTrackColor: cs.primary,
                    onChanged: (v) {},
                  ),
                ),
                InfoListRow(
                  title: 'SMS alerts',
                  icon: Icons.sms_outlined,
                  trailing: Switch.adaptive(
                    value: false,
                    activeTrackColor: cs.primary,
                    onChanged: (v) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionTitle(title: 'ACCOUNT & SECURITY'),
            const SizedBox(height: 8),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Change Password',
                  icon: Icons.lock_reset_outlined,
                  trailing: Icon(Icons.open_in_new, size: 18, color: cs.outline),
                  onTap: () => context.push('/change-password'),
                ),
                InfoListRow(
                  title: 'Two-Factor Authentication',
                  subtitle: 'Strongly Recommended',
                  icon: Icons.verified_user_outlined,
                  iconAccent: cs.secondary,
                  trailing: Switch.adaptive(
                    value: false,
                    activeTrackColor: cs.primary,
                    onChanged: (v) {},
                  ),
                ),
                InfoListRow(
                  title: 'Trusted Devices',
                  icon: Icons.devices_outlined,
                  showChevron: true,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionTitle(title: 'APP SETTINGS'),
            const SizedBox(height: 8),
            InfoListCard(
              children: [
                InfoListRow(
                  title: 'Language',
                  subtitle: _getLocaleLabel(locale),
                  icon: Icons.language_outlined,
                  showChevron: true,
                  onTap: () => _showLanguageSheet(context, ref),
                ),
                InfoListRow(
                  title: 'Data Usage',
                  icon: Icons.data_usage_outlined,
                  showChevron: true,
                  onTap: () {},
                ),
                InfoListRow(
                  title: 'Clear Cache',
                  subtitle: '42.5 MB used',
                  icon: Icons.delete_sweep_outlined,
                  iconAccent: cs.error,
                  trailing: Icon(Icons.cleaning_services_outlined, size: 18, color: cs.outline),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Log out from all sessions',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _getLocaleLabel(Locale? locale) {
    if (locale == null) return 'System default';
    if (locale.languageCode == 'en') return 'English (US)';
    if (locale.languageCode == 'fr') return 'Français';
    return 'English (US)';
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    showAppSheet(
      context,
      (context) => const ThemeSelectionSheet(),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    showAppSheet(
      context,
      (context) => const LanguageSelectionSheet(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
