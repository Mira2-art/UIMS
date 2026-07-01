import 'package:flutter/material.dart';

import '../../../core/constants/app_typography.dart';
import '../display/trustech_avatar.dart';

/// What sits at the start (leading) of [AppHeaderBar].
enum AppHeaderLeading { none, back, menu, avatar, custom }

/// The app's single custom app bar. Implements [PreferredSizeWidget] so it drops
/// straight into `Scaffold(appBar: ...)`.
///
/// Configurable per screen:
///  * **leading** — back arrow, drawer/menu icon, user avatar, a custom widget, or none.
///  * **title** — plain text or a custom [titleWidget] (e.g. the brand wordmark).
///  * **actions** — any trailing widgets; plus a built-in notification bell (with
///    unread badge) when [showNotification] is true.
///
/// Convenience constructors: [AppHeaderBar.home], [AppHeaderBar.back], [AppHeaderBar.menu].
class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading = AppHeaderLeading.back,
    this.customLeading,
    this.onBack,
    this.onMenu,
    this.onAvatarTap,
    this.avatarName,
    this.avatarUrl,
    this.actions = const [],
    this.showNotification = false,
    this.unreadCount = 0,
    this.onNotification,
    this.centerTitle = false,
    this.backgroundColor,
    this.titleColor,
    this.height = kToolbarHeight,
  });

  /// Home variant: avatar + wordmark + notification bell.
  const AppHeaderBar.home({
    super.key,
    this.title = 'Trustech',
    this.avatarName,
    this.avatarUrl,
    this.onAvatarTap,
    this.unreadCount = 0,
    this.onNotification,
    this.actions = const [],
    this.backgroundColor,
    this.titleColor,
    this.height = kToolbarHeight,
  })  : leading = AppHeaderLeading.avatar,
        titleWidget = null,
        customLeading = null,
        onBack = null,
        onMenu = null,
        showNotification = true,
        centerTitle = false;

  /// Back variant: back arrow + title.
  const AppHeaderBar.back({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
    this.showNotification = false,
    this.unreadCount = 0,
    this.onNotification,
    this.centerTitle = false,
    this.backgroundColor,
    this.titleColor,
    this.height = kToolbarHeight,
  })  : leading = AppHeaderLeading.back,
        titleWidget = null,
        customLeading = null,
        onMenu = null,
        onAvatarTap = null,
        avatarName = null,
        avatarUrl = null;

  /// Menu variant: drawer (hamburger) icon + title.
  const AppHeaderBar.menu({
    super.key,
    required this.title,
    this.onMenu,
    this.actions = const [],
    this.showNotification = false,
    this.unreadCount = 0,
    this.onNotification,
    this.centerTitle = false,
    this.backgroundColor,
    this.titleColor,
    this.height = kToolbarHeight,
  })  : leading = AppHeaderLeading.menu,
        titleWidget = null,
        customLeading = null,
        onBack = null,
        onAvatarTap = null,
        avatarName = null,
        avatarUrl = null;

  final String? title;
  final Widget? titleWidget;
  final AppHeaderLeading leading;
  final Widget? customLeading;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final VoidCallback? onAvatarTap;
  final String? avatarName;
  final String? avatarUrl;
  final List<Widget> actions;
  final bool showNotification;
  final int unreadCount;
  final VoidCallback? onNotification;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  Widget? _buildLeading(BuildContext context) {
    switch (leading) {
      case AppHeaderLeading.none:
        return null;
      case AppHeaderLeading.back:
        return IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        );
      case AppHeaderLeading.menu:
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenu ?? () => Scaffold.of(context).openDrawer(),
        );
      case AppHeaderLeading.avatar:
        return Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: onAvatarTap,
            child: TrustechAvatar(name: avatarName, imageUrl: avatarUrl, radius: 18),
          ),
        );
      case AppHeaderLeading.custom:
        return customLeading;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAvatar = leading == AppHeaderLeading.avatar;

    final resolvedActions = <Widget>[
      ...actions,
      if (showNotification)
        _NotificationButton(
          unreadCount: unreadCount,
          onTap: onNotification,
          color: titleColor ?? cs.primary,
        ),
    ];

    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      leading: _buildLeading(context),
      leadingWidth: isAvatar ? 56 : null,
      titleSpacing: isAvatar ? 4 : null,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TrustechTypography.h2.copyWith(
                    fontSize: isAvatar ? 22 : 20,
                    fontWeight: isAvatar ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: isAvatar ? -0.3 : -0.4,
                    color: titleColor ?? (isAvatar ? cs.primary : cs.onSurface),
                  ),
                )
              : null),
      actions: resolvedActions.isEmpty ? null : resolvedActions,
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.unreadCount, required this.onTap, required this.color});
  final int unreadCount;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: color),
          onPressed: onTap,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
