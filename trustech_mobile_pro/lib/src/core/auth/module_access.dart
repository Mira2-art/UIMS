import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock signed-in roles for the UI-only phase. Swap for real session roles when
/// auth is wired. Tweak this set to preview how the Workspace/drawer adapt.
/// TODO(backend:) derive from the authenticated user's roles.
final currentRolesProvider = Provider<Set<Role>>(
  (ref) => const {Role.lecturer, Role.registrar, Role.finance, Role.admin},
);

/// Staff roles (super-admin is out of scope for this app).
enum Role { lecturer, registrar, finance, hr, admin, staff }

/// Top-level sections of the Workspace hub / drawer directory (spec §6.2).
enum ModuleSection {
  teaching,
  studentsAdmissions,
  academics,
  finance,
  people,
  administration,
  communication,
}

extension ModuleSectionLabel on ModuleSection {
  String get label => switch (this) {
        ModuleSection.teaching => 'Teaching',
        ModuleSection.studentsAdmissions => 'Students & Admissions',
        ModuleSection.academics => 'Academics',
        ModuleSection.finance => 'Finance',
        ModuleSection.people => 'People',
        ModuleSection.administration => 'Administration',
        ModuleSection.communication => 'Communication',
      };
}

/// A single launchable module entry (feeds the Workspace grid, the drawer
/// directory, and — later — the route guard). One source of truth.
@immutable
class ModuleEntry {
  const ModuleEntry({
    required this.title,
    required this.icon,
    required this.route,
    required this.section,
    required this.roles,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String route;
  final ModuleSection section;

  /// Roles that may see this module. A user sees the union of their roles.
  final Set<Role> roles;
}

/// The full staff module catalog (superset). `moduleAccess` filters it by role.
const List<ModuleEntry> kAllModules = [
  // Teaching — LECTURER
  ModuleEntry(title: 'My Courses', subtitle: 'Courses you teach', icon: Icons.menu_book_outlined, route: '/courses', section: ModuleSection.teaching, roles: {Role.lecturer}),
  // Students & Admissions — REGISTRAR (+ view for ADMIN/FINANCE/LECTURER)
  ModuleEntry(title: 'Students', subtitle: 'Records & profiles', icon: Icons.school_outlined, route: '/students', section: ModuleSection.studentsAdmissions, roles: {Role.registrar, Role.admin, Role.finance, Role.lecturer}),
  ModuleEntry(title: 'Applicants', subtitle: 'Admissions', icon: Icons.how_to_reg_outlined, route: '/applicants', section: ModuleSection.studentsAdmissions, roles: {Role.registrar, Role.admin}),
  ModuleEntry(title: 'Enrollments', subtitle: 'Manage enrollments', icon: Icons.app_registration_outlined, route: '/enrollments', section: ModuleSection.studentsAdmissions, roles: {Role.registrar}),
  // Academics — REGISTRAR (+ view ADMIN)
  ModuleEntry(title: 'Academic Structure', subtitle: 'Faculties, departments, programs', icon: Icons.account_tree_outlined, route: '/academics/faculties', section: ModuleSection.academics, roles: {Role.registrar, Role.admin}),
  ModuleEntry(title: 'Course Catalog', subtitle: 'Courses & prerequisites', icon: Icons.library_books_outlined, route: '/academics/catalog', section: ModuleSection.academics, roles: {Role.registrar, Role.admin}),
  ModuleEntry(title: 'Semesters', subtitle: 'Calendar & windows', icon: Icons.event_outlined, route: '/academics/semesters', section: ModuleSection.academics, roles: {Role.registrar, Role.admin}),
  // Finance — FINANCE (+ view ADMIN)
  ModuleEntry(title: 'Fee Structures', icon: Icons.receipt_long_outlined, route: '/finance/fee-structures', section: ModuleSection.finance, roles: {Role.finance, Role.admin}),
  ModuleEntry(title: 'Charges', subtitle: 'Billing', icon: Icons.request_quote_outlined, route: '/finance/charges', section: ModuleSection.finance, roles: {Role.finance, Role.admin}),
  ModuleEntry(title: 'Payments', icon: Icons.payments_outlined, route: '/finance/payments', section: ModuleSection.finance, roles: {Role.finance, Role.admin}),
  ModuleEntry(title: 'Scholarships', icon: Icons.workspace_premium_outlined, route: '/finance/scholarships', section: ModuleSection.finance, roles: {Role.finance, Role.admin}),
  ModuleEntry(title: 'Finance Reports', icon: Icons.insights_outlined, route: '/finance/reports', section: ModuleSection.finance, roles: {Role.finance, Role.admin}),
  // People (HR) — HR (+ view ADMIN)
  ModuleEntry(title: 'Lecturers', subtitle: 'Staff records', icon: Icons.badge_outlined, route: '/people/lecturers', section: ModuleSection.people, roles: {Role.hr, Role.admin}),
  // Administration — ADMIN (non-super)
  ModuleEntry(title: 'Admin Dashboard', icon: Icons.dashboard_outlined, route: '/admin/dashboard', section: ModuleSection.administration, roles: {Role.admin}),
  ModuleEntry(title: 'Users', icon: Icons.group_outlined, route: '/admin/users', section: ModuleSection.administration, roles: {Role.admin}),
  ModuleEntry(title: 'Roles & Permissions', icon: Icons.admin_panel_settings_outlined, route: '/admin/roles', section: ModuleSection.administration, roles: {Role.admin}),
  ModuleEntry(title: 'Audit Logs', icon: Icons.fact_check_outlined, route: '/admin/audit-logs', section: ModuleSection.administration, roles: {Role.admin}),
  ModuleEntry(title: 'System Configs', icon: Icons.settings_suggest_outlined, route: '/admin/configs', section: ModuleSection.administration, roles: {Role.admin}),
  ModuleEntry(title: 'Email Logs', icon: Icons.mark_email_read_outlined, route: '/admin/email-logs', section: ModuleSection.administration, roles: {Role.admin}),
  // Communication — STAFF/REGISTRAR/FINANCE/ADMIN
  ModuleEntry(title: 'Announcements', icon: Icons.campaign_outlined, route: '/announcements', section: ModuleSection.communication, roles: {Role.staff, Role.registrar, Role.finance, Role.admin}),
  ModuleEntry(title: 'Broadcast', subtitle: 'Send notification', icon: Icons.podcasts_outlined, route: '/broadcast-notification', section: ModuleSection.communication, roles: {Role.registrar, Role.finance, Role.admin}),
];

/// Modules visible to a user holding [roles] (union of their roles).
List<ModuleEntry> moduleAccess(Set<Role> roles) =>
    kAllModules.where((m) => m.roles.intersection(roles).isNotEmpty).toList(growable: false);

/// Modules grouped by section, for the Workspace grid and drawer directory.
Map<ModuleSection, List<ModuleEntry>> moduleAccessBySection(Set<Role> roles) {
  final out = <ModuleSection, List<ModuleEntry>>{};
  for (final m in moduleAccess(roles)) {
    out.putIfAbsent(m.section, () => <ModuleEntry>[]).add(m);
  }
  return out;
}
