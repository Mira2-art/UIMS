// Roles: REGISTRAR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/students/providers/students_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({super.key, this.studentId});
  final String? studentId;
  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _phone = TextEditingController();
  late final TextEditingController _matric = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _matric.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.studentId != null;
    final student = widget.studentId == null
        ? null
        : ref.watch(studentProvider(widget.studentId!));
    final cs = Theme.of(context).colorScheme;
    if (student != null && _name.text.isEmpty) {
      _name.text = student.name;
      _email.text = student.email;
      _phone.text = student.phone;
      _matric.text = student.matricNo;
    }
    return Scaffold(
      appBar: AppHeaderBar.back(
        title: isEditing ? 'Edit Student' : 'Create Student',
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TrustechButton(
                  label: 'Cancel',
                  variant: TrustechButtonVariant.outline,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TrustechButton(
                  label: isEditing ? 'Save Changes' : 'Create Student',
                  icon: Icons.save,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            const _SectionTitle(icon: Icons.person, title: 'User Account'),
            const SizedBox(height: 10),
            InfoListCard(
              children: [
                SegmentedSelectorRow(
                  label: 'Create new account',
                  selected: true,
                  onTap: () {},
                ),
                SegmentedSelectorRow(
                  label: 'Link existing account',
                  selected: false,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 14),
            TrustechTextField(
              controller: _name,
              label: 'Full Name',
              hintText: 'e.g. John Doe',
            ),
            const SizedBox(height: 12),
            TrustechTextField(
              controller: _email,
              label: 'Email',
              hintText: 'john.doe@trustech.edu',
            ),
            const SizedBox(height: 18),
            const _SectionTitle(icon: Icons.school, title: 'Academic Details'),
            const SizedBox(height: 10),
            TrustechTextField(
              controller: _matric,
              label: 'Matric Number',
              hintText: 'T-2024-001',
            ),
            const SizedBox(height: 12),
            const InfoListCard(
              children: [
                InfoListRow(
                  title: 'Programme',
                  subtitle: 'B.Sc. Computer Science',
                  icon: Icons.school_outlined,
                ),
                InfoListRow(
                  title: 'Level',
                  subtitle: '100L',
                  icon: Icons.stairs_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionTitle(
              icon: Icons.verified_user,
              title: 'Initial Status',
            ),
            const SizedBox(height: 10),
            InfoListCard(
              children: [
                SegmentedSelectorRow(
                  label: 'Active',
                  selected: true,
                  onTap: () {},
                ),
                SegmentedSelectorRow(
                  label: 'Pending verification',
                  selected: false,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'All fields use static mock data until the student create/update API is wired.',
              style: TrustechTypography.caption.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(width: 8),
        Text(title, style: TrustechTypography.h3.copyWith(color: cs.onSurface)),
      ],
    );
  }
}
