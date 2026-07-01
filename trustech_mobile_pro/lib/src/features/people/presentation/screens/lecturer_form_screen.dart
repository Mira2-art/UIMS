// Roles: HR, ADMIN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustech_mobile_pro/src/core/constants/app_typography.dart';
import 'package:trustech_mobile_pro/src/features/people/providers/people_providers.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

class LecturerFormScreen extends ConsumerStatefulWidget {
  const LecturerFormScreen({super.key, this.lecturerId});
  final String? lecturerId;
  @override
  ConsumerState<LecturerFormScreen> createState() => _LecturerFormScreenState();
}

class _LecturerFormScreenState extends ConsumerState<LecturerFormScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _staff = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _staff.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lecturerId != null;
    final lecturer = widget.lecturerId == null
        ? null
        : ref.watch(lecturerProvider(widget.lecturerId!));
    final cs = Theme.of(context).colorScheme;
    if (lecturer != null && _name.text.isEmpty) {
      _name.text = lecturer.name;
      _email.text = lecturer.email;
      _phone.text = lecturer.phone;
      _staff.text = lecturer.staffId;
    }
    return Scaffold(
      appBar: const AppHeaderBar.back(title: 'Staff Management'),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TrustechButton(
                  label: 'Cancel',
                  variant: TrustechButtonVariant.text,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TrustechButton(
                  label: isEditing ? 'Save Lecturer' : 'Create Lecturer',
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
            Text(
              isEditing ? 'Edit Lecturer' : 'Create New Lecturer',
              style: TrustechTypography.displayLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 18),
            const _Section(icon: Icons.person, title: 'Personal Information'),
            const SizedBox(height: 10),
            TrustechTextField(
              controller: _name,
              label: 'Full Name',
              hintText: 'e.g. Dr. Jonathan Smith',
            ),
            const SizedBox(height: 12),
            TrustechTextField(
              controller: _email,
              label: 'Email',
              hintText: 'j.smith@trustech.edu',
            ),
            const SizedBox(height: 12),
            TrustechTextField(
              controller: _phone,
              label: 'Phone',
              hintText: '+1 (555) 000-0000',
            ),
            const SizedBox(height: 18),
            const _Section(icon: Icons.school, title: 'Academic Appointment'),
            const SizedBox(height: 10),
            TrustechTextField(
              controller: _staff,
              label: 'Staff ID',
              hintText: 'LEC-2024-001',
            ),
            const SizedBox(height: 12),
            const InfoListCard(
              children: [
                InfoListRow(
                  title: 'Department',
                  subtitle: 'Computer Science',
                  icon: Icons.account_tree,
                ),
                InfoListRow(
                  title: 'Rank',
                  subtitle: 'Senior Lecturer',
                  icon: Icons.workspace_premium,
                ),
                InfoListRow(
                  title: 'Specialization',
                  subtitle: 'Quantum Computing',
                  icon: Icons.psychology,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _Section(icon: Icons.security, title: 'Account Settings'),
            const SizedBox(height: 10),
            InfoListCard(
              children: [
                SegmentedSelectorRow(
                  label: 'Full staff access',
                  selected: false,
                  onTap: () {},
                ),
                SegmentedSelectorRow(
                  label: 'Lecturer access only',
                  selected: true,
                  onTap: () {},
                ),
                SegmentedSelectorRow(
                  label: 'Limited access',
                  selected: false,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title});
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
