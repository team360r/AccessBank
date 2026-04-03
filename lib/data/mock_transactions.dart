import 'models/transaction.dart';

class MockTransactions {
  static final List<Transaction> all = [
    // Day 1 (today)
    Transaction(
      id: 'txn_001',
      accountId: 'acc_001',
      amount: -67.43,
      date: DateTime(2026, 4, 3),
      merchant: 'Whole Foods Market',
      category: 'Groceries',
      type: TransactionType.debit,
    ),
    // Day 2
    Transaction(
      id: 'txn_002',
      accountId: 'acc_001',
      amount: -12.80,
      date: DateTime(2026, 4, 2),
      merchant: 'Blue Bottle Coffee',
      category: 'Dining',
      type: TransactionType.debit,
    ),
    Transaction(
      id: 'txn_003',
      accountId: 'acc_003',
      amount: -48.95,
      date: DateTime(2026, 4, 2),
      merchant: 'Amazon',
      category: 'Shopping',
      type: TransactionType.debit,
    ),
    // Day 5
    Transaction(
      id: 'txn_004',
      accountId: 'acc_001',
      amount: 3800.00,
      date: DateTime(2026, 3, 31),
      merchant: 'Acme Corp Payroll',
      category: 'Income',
      type: TransactionType.credit,
    ),
    // Day 6
    Transaction(
      id: 'txn_005',
      accountId: 'acc_001',
      amount: -2100.00,
      date: DateTime(2026, 3, 30),
      merchant: 'Parkview Apartments',
      category: 'Rent',
      type: TransactionType.debit,
    ),
    Transaction(
      id: 'txn_006',
      accountId: 'acc_002',
      amount: 500.00,
      date: DateTime(2026, 3, 30),
      merchant: 'Transfer from Checking',
      category: 'Transfer',
      type: TransactionType.transfer,
    ),
    // Day 8
    Transaction(
      id: 'txn_007',
      accountId: 'acc_001',
      amount: -89.20,
      date: DateTime(2026, 3, 28),
      merchant: 'PG&E Utilities',
      category: 'Utilities',
      type: TransactionType.debit,
    ),
    Transaction(
      id: 'txn_008',
      accountId: 'acc_003',
      amount: -34.50,
      date: DateTime(2026, 3, 28),
      merchant: 'Chipotle Mexican Grill',
      category: 'Dining',
      type: TransactionType.debit,
    ),
    // Day 10
    Transaction(
      id: 'txn_009',
      accountId: 'acc_001',
      amount: -200.00,
      date: DateTime(2026, 3, 26),
      merchant: 'Chase ATM Withdrawal',
      category: 'ATM',
      type: TransactionType.debit,
    ),
    Transaction(
      id: 'txn_010',
      accountId: 'acc_003',
      amount: -156.00,
      date: DateTime(2026, 3, 26),
      merchant: 'Spotify Premium',
      category: 'Entertainment',
      type: TransactionType.debit,
    ),
    // Day 14
    Transaction(
      id: 'txn_011',
      accountId: 'acc_001',
      amount: -54.30,
      date: DateTime(2026, 3, 22),
      merchant: 'Trader Joe\'s',
      category: 'Groceries',
      type: TransactionType.debit,
    ),
    Transaction(
      id: 'txn_012',
      accountId: 'acc_003',
      amount: -22.99,
      date: DateTime(2026, 3, 22),
      merchant: 'Netflix',
      category: 'Entertainment',
      type: TransactionType.debit,
    ),
    // Day 17
    Transaction(
      id: 'txn_013',
      accountId: 'acc_001',
      amount: -310.00,
      date: DateTime(2026, 3, 19),
      merchant: 'Delta Airlines',
      category: 'Travel',
      type: TransactionType.debit,
    ),
    Transaction(
      id: 'txn_014',
      accountId: 'acc_001',
      amount: 150.00,
      date: DateTime(2026, 3, 19),
      merchant: 'Venmo Transfer',
      category: 'Transfer',
      type: TransactionType.credit,
    ),
    // Day 20
    Transaction(
      id: 'txn_015',
      accountId: 'acc_003',
      amount: -78.45,
      date: DateTime(2026, 3, 16),
      merchant: 'Target',
      category: 'Shopping',
      type: TransactionType.debit,
    ),
    // Day 24
    Transaction(
      id: 'txn_016',
      accountId: 'acc_001',
      amount: 3800.00,
      date: DateTime(2026, 3, 12),
      merchant: 'Acme Corp Payroll',
      category: 'Income',
      type: TransactionType.credit,
    ),
    // Day 27
    Transaction(
      id: 'txn_017',
      accountId: 'acc_001',
      amount: -42.60,
      date: DateTime(2026, 3, 9),
      merchant: 'Shell Gas Station',
      category: 'Transportation',
      type: TransactionType.debit,
    ),
    Transaction(
      id: 'txn_018',
      accountId: 'acc_003',
      amount: -95.00,
      date: DateTime(2026, 3, 9),
      merchant: 'Pharmacy CVS',
      category: 'Health',
      type: TransactionType.debit,
    ),
    // Day 30
    Transaction(
      id: 'txn_019',
      accountId: 'acc_001',
      amount: -29.99,
      date: DateTime(2026, 3, 6),
      merchant: 'Adobe Creative Cloud',
      category: 'Subscriptions',
      type: TransactionType.debit,
    ),
    Transaction(
      id: 'txn_020',
      accountId: 'acc_002',
      amount: 200.00,
      date: DateTime(2026, 3, 6),
      merchant: 'Transfer from Checking',
      category: 'Transfer',
      type: TransactionType.transfer,
    ),
  ];

  static List<Transaction> forAccount(String accountId) =>
      all.where((t) => t.accountId == accountId).toList();
}
