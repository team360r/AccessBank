enum TransactionType { debit, credit, transfer }

class Transaction {
  final String id;
  final String accountId;
  final double amount;
  final DateTime date;
  final String merchant;
  final String category;
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.date,
    required this.merchant,
    required this.category,
    required this.type,
  });
}
