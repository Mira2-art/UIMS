import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock/admin_mock.dart';

final usersProvider = Provider<List<User>>((ref) {
  // TODO(backend): replace with /admin/users
  return AdminMock.users;
});

final rolesProvider = Provider<List<Role>>((ref) {
  // TODO(backend): replace with /admin/roles
  return AdminMock.roles;
});

final auditLogsProvider = Provider<List<AuditLog>>((ref) {
  // TODO(backend): replace with /admin/audit-logs
  return AdminMock.auditLogs;
});

final auditLogDetailProvider = Provider.family<AuditLog?, String>((ref, id) {
  final all = ref.watch(auditLogsProvider);
  final matches = all.where((a) => a.id == id);
  return matches.isEmpty ? null : matches.first;
});

final systemConfigsProvider = Provider<List<SystemConfig>>((ref) {
  // TODO(backend): replace with /admin/configs
  return AdminMock.systemConfigs;
});

final emailLogsProvider = Provider<List<EmailLog>>((ref) {
  // TODO(backend): replace with /admin/email-logs
  return AdminMock.emailLogs;
});

final userDetailProvider = Provider.family<User?, String>((ref, id) {
  final all = ref.watch(usersProvider);
  final matches = all.where((u) => u.id == id);
  return matches.isEmpty ? null : matches.first;
});
