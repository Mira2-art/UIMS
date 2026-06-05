import 'package:flutter/material.dart';

/// Thin wrapper over [Scaffold] that standardises the app bar and safe-area
/// behaviour. Keeps screens terse and consistent; drop down to a raw
/// [Scaffold] only when a screen needs something this doesn't expose.
class TrustechScaffold extends StatelessWidget {
  const TrustechScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding = const EdgeInsets.all(16),
    this.safeArea = true,
    this.scrollable = false,
    this.centerTitle = false,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry padding;
  final bool safeArea;
  final bool scrollable;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);
    if (scrollable) {
      content = SingleChildScrollView(
        padding: padding,
        child: body,
      );
    }
    if (safeArea) content = SafeArea(child: content);

    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
              leading: leading,
              centerTitle: centerTitle,
            )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
