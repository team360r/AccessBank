enum AccountType { checking, savings, credit }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
  });
}
