import 'package:flutter/material.dart';

import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

/// Placeholder used by foundation stubs so the app compiles and every route is
/// reachable before features are implemented. Each feature agent replaces the
/// stub's `build()` with the real screen (keeping the class name + file path).
class StubScreen extends StatelessWidget {
  const StubScreen({super.key, required this.title, this.isTabRoot = false, this.note});

  final String title;
  final bool isTabRoot;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isTabRoot
          ? AppHeaderBar(title: title, leading: AppHeaderLeading.none)
          : AppHeaderBar.back(title: title),
      body: TrustechEmptyState(
        icon: Icons.construction_outlined,
        title: title,
        message: note ?? 'Screen stub — implementation pending.',
      ),
    );
  }
}
