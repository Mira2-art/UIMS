enum FeeStatus {
  active,
  draft,
  inactive;

  String get label => name.toUpperCase();
}

class FeeStructure {
  final String id;
  final String title;
  final String description;
  final String program;
  final double amount;
  final FeeStatus status;

  const FeeStructure({
    required this.id,
    required this.title,
    required this.description,
    required this.program,
    required this.amount,
    this.status = FeeStatus.active,
  });
}

enum ChargeStatus {
  pending,
  paid,
  overdue,
  partial;

  String get label => name.toUpperCase();
}

class ChargeItem {
  final String title;
  final String description;
  final double amount;

  const ChargeItem({
    required this.title,
    required this.description,
    required this.amount,
  });
}

class PaymentHistory {
  final String date;
  final String receiptNo;
  final String method;
  final double amount;

  const PaymentHistory({
    required this.date,
    required this.receiptNo,
    required this.method,
    required this.amount,
  });
}

class Charge {
  final String id;
  final String studentName;
  final String studentId;
  final String? studentAvatar;
  final String type;
  final double amount;
  final double paidAmount;
  final ChargeStatus status;
  final String dueDate;
  final String lastPaymentDate;
  final List<ChargeItem> items;
  final List<PaymentHistory> history;

  const Charge({
    required this.id,
    required this.studentName,
    required this.studentId,
    this.studentAvatar,
    required this.type,
    required this.amount,
    this.paidAmount = 0,
    required this.status,
    required this.dueDate,
    this.lastPaymentDate = '',
    this.items = const [],
    this.history = const [],
  });

  double get balance => amount - paidAmount;
}

class Payment {
  final String id;
  final String studentName;
  final String studentId;
  final String receiptNo;
  final String method;
  final DateTime date;
  final double amount;
  final String status; // 'Verified', 'Flagged'

  const Payment({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.receiptNo,
    required this.method,
    required this.date,
    required this.amount,
    this.status = 'Verified',
  });
}

class Scholarship {
  final String id;
  final String name;
  final String description;
  final double totalFund;
  final int recipientsCount;
  final String status; // 'Active', 'Review', 'Paused'

  const Scholarship({
    required this.id,
    required this.name,
    required this.description,
    required this.totalFund,
    required this.recipientsCount,
    this.status = 'Active',
  });
}

class FinanceMock {
  static const feeStructures = [
    FeeStructure(
      id: 'f1',
      title: 'Undergraduate Tuition',
      description: 'Annual academic instructional fee',
      program: 'Bachelor of Science, All Majors',
      amount: 4500.00,
    ),
    FeeStructure(
      id: 'f2',
      title: 'Laboratory & Equipment',
      description: 'Resource maintenance fee',
      program: 'Engineering & Natural Sciences',
      amount: 320.00,
    ),
    FeeStructure(
      id: 'f3',
      title: 'Athletic Facilities Fee',
      description: 'General student wellness fund',
      program: 'General Enrollment (All)',
      amount: 150.00,
    ),
    FeeStructure(
      id: 'f4',
      title: 'Graduate Library Access',
      description: 'Premium research resources',
      program: 'Masters & Doctoral Candidates',
      amount: 280.00,
      status: FeeStatus.draft,
    ),
  ];

  static const charges = [
    Charge(
      id: 'c1',
      studentName: 'Johnathan Smith',
      studentId: 'STU-2024-001',
      type: 'Housing & Residence',
      amount: 2450.00,
      paidAmount: 0,
      status: ChargeStatus.overdue,
      dueDate: 'Oct 15, 2023',
      items: [
        ChargeItem(title: 'Room Rent (Double Shared)', description: 'Accommodation for Fall Semester', amount: 2000.00),
        ChargeItem(title: 'Utilities & Internet', description: 'Monthly fixed charges', amount: 450.00),
      ],
    ),
    Charge(
      id: 'c2',
      studentName: 'Maria Chen',
      studentId: 'STU-2024-042',
      type: 'Science Lab Fees',
      amount: 125.00,
      paidAmount: 125.00,
      status: ChargeStatus.paid,
      dueDate: 'Sep 10, 2023',
    ),
    Charge(
      id: 'c3',
      studentName: 'Julian D. Martinez',
      studentId: 'ST-88219',
      type: 'Combined Semester Fees',
      amount: 1425.00,
      paidAmount: 800.00,
      status: ChargeStatus.partial,
      dueDate: 'Oct 20, 2023',
      lastPaymentDate: 'Oct 12, 2023',
      items: [
        ChargeItem(title: 'Semester Tuition Fee (Fall)', description: 'Base academic charges for Q3-Q4', amount: 1200.00),
        ChargeItem(title: 'Advanced Physics Lab Fee', description: 'Consumables and equipment rental', amount: 150.00),
        ChargeItem(title: 'Extracurricular: Robotics Club', description: 'Annual membership and kit', amount: 75.00),
      ],
      history: [
        PaymentHistory(date: 'Oct 12, 2023', receiptNo: 'RCP-10292', method: 'Bank Transfer', amount: 500.00),
        PaymentHistory(date: 'Sep 15, 2023', receiptNo: 'RCP-09881', method: 'Credit Card', amount: 300.00),
      ],
    ),
  ];

  static final payments = [
    Payment(
      id: 'p1',
      studentName: 'Julian Sterling',
      studentId: 'STU-2024-001',
      receiptNo: 'PAY-2024-00128',
      method: 'Bank Transfer (IMPS)',
      date: DateTime(2023, 10, 24),
      amount: 2450.00,
    ),
    Payment(
      id: 'p2',
      studentName: 'Amara Okafor',
      studentId: 'STU-2024-042',
      receiptNo: 'PAY-2024-00129',
      method: 'Card Payment',
      date: DateTime(2023, 10, 25),
      amount: 1100.00,
      status: 'Flagged',
    ),
    Payment(
      id: 'p3',
      studentName: 'Marcus Thorne',
      studentId: 'ST-88219',
      receiptNo: 'PAY-2024-00130',
      method: 'Bank Transfer',
      date: DateTime(2023, 10, 25),
      amount: 5200.00,
    ),
    Payment(
      id: 'p4',
      studentName: 'Elena Rodriguez',
      studentId: 'STU-2024-003',
      receiptNo: 'PAY-2024-00131',
      method: 'Digital Wallet',
      date: DateTime(2023, 10, 26),
      amount: 850.00,
    ),
  ];

  static const scholarships = [
    Scholarship(
      id: 's1',
      name: 'Academic Excellence Grant',
      description: 'Merit-based institutional support',
      totalFund: 450000.0,
      recipientsCount: 125,
      status: 'Active',
    ),
    Scholarship(
      id: 's2',
      name: 'Community Impact Award',
      description: 'Leadership and service focus',
      totalFund: 220000.0,
      recipientsCount: 54,
      status: 'Review',
    ),
    Scholarship(
      id: 's3',
      name: 'STEM Innovation Fellowship',
      description: 'Advanced research in sciences',
      totalFund: 380000.0,
      recipientsCount: 82,
      status: 'Active',
    ),
    Scholarship(
      id: 's4',
      name: 'Legacy Arts Endowment',
      description: 'Historical arts preservation',
      totalFund: 190000.0,
      recipientsCount: 0,
      status: 'Paused',
    ),
  ];
}
