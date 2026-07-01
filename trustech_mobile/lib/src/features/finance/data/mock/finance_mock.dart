enum ChargeStatus {
  paid,
  partial,
  outstanding,
  waived;

  String get label => name.toUpperCase();
}

class Charge {
  final String id;
  final String title;
  final String category;
  final double amount;
  final double balance;
  final ChargeStatus status;
  final DateTime dueDate;
  final String semester;
  final String? description;
  final List<PaymentHistory>? history;

  const Charge({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.balance,
    required this.status,
    required this.dueDate,
    required this.semester,
    this.description,
    this.history,
  });
}

class PaymentHistory {
  final String id;
  final DateTime date;
  final double amount;
  final String method;
  final String receiptNo;
  final bool isReversed;

  const PaymentHistory({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.receiptNo,
    this.isReversed = false,
  });
}

class Scholarship {
  final String id;
  final String name;
  final double amount;
  final String semester;
  final String status;

  const Scholarship({
    required this.id,
    required this.name,
    required this.amount,
    required this.semester,
    required this.status,
  });
}

class FinanceOverview {
  final double totalBalance;
  final DateTime nextDueDate;
  final double nextDueAmount;
  final List<Charge> recentCharges;

  const FinanceOverview({
    required this.totalBalance,
    required this.nextDueDate,
    required this.nextDueAmount,
    required this.recentCharges,
  });
}

class FinanceMock {
  static final charges = [
    Charge(
      id: '1',
      title: 'Tuition & Fees',
      category: 'Standard Undergraduate',
      amount: 3850.00,
      balance: 3850.00,
      status: ChargeStatus.outstanding,
      dueDate: DateTime(2023, 10, 27),
      semester: 'Fall 2023',
      description: 'Full-time undergraduate tuition for Fall 2023 semester.',
      history: [
        PaymentHistory(
          id: 'p1',
          date: DateTime(2023, 9, 1),
          amount: 500.0,
          method: 'Credit Card',
          receiptNo: 'REC-992831',
        ),
      ],
    ),
    Charge(
      id: '2',
      title: 'Lab Fees',
      category: 'Computer Science 301',
      amount: 350.00,
      balance: 350.00,
      status: ChargeStatus.outstanding,
      dueDate: DateTime(2023, 10, 27),
      semester: 'Fall 2023',
    ),
    Charge(
      id: '3',
      title: 'Library Fines',
      category: 'Overdue: Design Systems v1',
      amount: 50.00,
      balance: 50.00,
      status: ChargeStatus.outstanding,
      dueDate: DateTime(2023, 10, 20),
      semester: 'Fall 2023',
    ),
    Charge(
      id: '4',
      title: 'Academic Grant',
      category: 'Applied Credit',
      amount: -1200.00,
      balance: -1200.00,
      status: ChargeStatus.paid,
      dueDate: DateTime(2023, 8, 15),
      semester: 'Fall 2023',
    ),
  ];

  static final financeOverview = FinanceOverview(
    totalBalance: 4250.00,
    nextDueDate: DateTime(2023, 10, 27),
    nextDueAmount: 4250.00,
    recentCharges: charges,
  );

  static final payments = [
    PaymentHistory(
      id: 'p1',
      date: DateTime(2023, 9, 15),
      amount: 1250.00,
      method: 'Bank Transfer',
      receiptNo: 'TRX-882104',
    ),
    PaymentHistory(
      id: 'p2',
      date: DateTime(2023, 8, 10),
      amount: 450.00,
      method: 'Cash',
      receiptNo: 'REC-771029',
      isReversed: true,
    ),
  ];

  static final scholarships = [
    const Scholarship(
      id: 's1',
      name: 'Excellence Merit Award',
      amount: 2500.00,
      semester: 'Fall 2023',
      status: 'Awarded',
    ),
    const Scholarship(
      id: 's2',
      name: 'STEM Grant',
      amount: 1000.00,
      semester: 'Spring 2023',
      status: 'Paid',
    ),
  ];
}
