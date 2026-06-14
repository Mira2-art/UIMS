// Roles: LECTURER
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/teaching/providers/teaching_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class CourseAnnounceScreen extends ConsumerStatefulWidget {
  const CourseAnnounceScreen({super.key, required this.courseId});
  final String courseId;
  @override
  ConsumerState<CourseAnnounceScreen> createState() =>
      _CourseAnnounceScreenState();
}

class _CourseAnnounceScreenState extends ConsumerState<CourseAnnounceScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _priority = 'Normal';
  bool _email = false;
  bool _push = true;
  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(teachingCourseProvider(widget.courseId));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Compose Announcement'),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TrustechButton(
            label: 'Send Announcement',
            icon: Icons.send_outlined,
            onPressed: () {},
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Course > ${course?.code ?? 'Course'}',
              style: TrustechTypography.caption.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Compose Announcement',
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TrustechCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrustechTextField(
                    controller: _titleController,
                    label: 'Title Field',
                    hintText: 'e.g. Midterm Results & Feedback',
                  ),
                  const SizedBox(height: 14),
                  TrustechTextField(
                    controller: TextEditingController(
                      text: '${course?.code ?? 'Course'} Students',
                    ),
                    label: 'Target Field',
                    prefixIcon: Icons.group_outlined,
                    enabled: false,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.format_bold),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_italic),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_list_bulleted),
                        onPressed: () {},
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.link),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  TrustechTextField(
                    controller: _messageController,
                    hintText: 'Type your announcement here...',
                    maxLines: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TrustechCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority',
                    style: TrustechTypography.h3.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 8),
                  SegmentedSelectorRow(
                    label: 'Normal Priority',
                    selected: _priority == 'Normal',
                    leadingIcon: Icons.notifications_outlined,
                    onTap: () => setState(() => _priority = 'Normal'),
                  ),
                  SegmentedSelectorRow(
                    label: 'Urgent Alert',
                    selected: _priority == 'Urgent',
                    leadingIcon: Icons.priority_high_outlined,
                    onTap: () => setState(() => _priority = 'Urgent'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TrustechCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _email,
                    onChanged: (v) => setState(() => _email = v),
                    title: const Text('Send Email Copy'),
                  ),
                  SwitchListTile(
                    value: _push,
                    onChanged: (v) => setState(() => _push = v),
                    title: const Text('Push Notification'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Preview',
                        style: TrustechTypography.h3.copyWith(
                          color: cs.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Students will see this in their announcement feed.',
                        style: TrustechTypography.caption.copyWith(
                          color: cs.onPrimary.withValues(alpha: .86),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: -12,
                    bottom: -20,
                    child: Icon(
                      Icons.campaign,
                      size: 110,
                      color: cs.onPrimary.withValues(alpha: .12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }
}
