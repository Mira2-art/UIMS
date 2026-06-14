import 'package:trustech_mobile_pro/src/features/students/data/mock/students_mock.dart';
import 'package:trustech_mobile_pro/src/shared/ui_kit/ui_kit.dart';

/// Shared mapping of [StudentStatus] → [StatusChip] kind (list + detail screens).
extension StudentStatusChip on StudentStatus {
  StatusKind get chipKind => switch (this) {
    StudentStatus.active => StatusKind.success,
    StudentStatus.probation => StatusKind.warning,
    StudentStatus.suspended => StatusKind.error,
    StudentStatus.alumni => StatusKind.neutral,
  };
}
