import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';
import '../display/trustech_avatar.dart';
import '../layout/brand_gradient_header.dart';

/// One entry in [AppDrawer].
class AppDrawerItem {
  const AppDrawerItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final String? badge;
}

/// The navigation drawer opened from [AppHeaderBar]'s menu icon.
///
/// Header shows the user (avatar, name, subtitle) on a brand gradient; the body
/// lists [items]; an optional [onSignOut] renders a separated destructive action
/// at the bottom. Provide the items per app/role.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.items,
    this.name,
    this.subtitle,
    this.email,
    this.avatarName,
    this.avatarUrl,
    this.onHeaderTap,
    this.onSignOut,
    this.signOutLabel = 'Sign out',
  });

  final List<AppDrawerItem> items;
  final String? name;
  final String? subtitle;
  final String? email;
  final String? avatarName;
  final String? avatarUrl;
  final VoidCallback? onHeaderTap;
  final VoidCallback? onSignOut;
  final String signOutLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Brand header
          SafeArea(
            bottom: false,
            child: GestureDetector(
              onTap: onHeaderTap,
              child: BrandGradientHeader(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TrustechAvatar(
                      name: avatarName ?? name,
                      imageUrl: avatarUrl,
                      radius: 28,
                    ),
                    const SizedBox(height: 12),
                    if (name != null)
                      Text(
                        name!,
                        style: TrustechTypography.h3.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: TrustechTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ),
                    if (email != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          email!,
                          style: TrustechTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.75)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final item in items)
                  ListTile(
                    leading: Icon(item.icon, color: item.selected ? cs.primary : cs.onSurfaceVariant),
                    title: Text(
                      item.label,
                      style: TrustechTypography.bodyLarge.copyWith(
                        fontWeight: item.selected ? FontWeight.w700 : FontWeight.w500,
                        color: item.selected ? cs.primary : cs.onSurface,
                      ),
                    ),
                    trailing: item.badge != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(item.badge!, style: TrustechTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: cs.secondary)),
                          )
                        : null,
                    selected: item.selected,
                    selectedTileColor: cs.primary.withValues(alpha: 0.08),
                    onTap: item.onTap,
                  ),
              ],
            ),
          ),

          // Sign out (separated)
          if (onSignOut != null) ...[
            Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
            SafeArea(
              top: false,
              child: ListTile(
                leading: Icon(Icons.logout, color: cs.error),
                title: Text(signOutLabel, style: TrustechTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: cs.error)),
                onTap: onSignOut,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
